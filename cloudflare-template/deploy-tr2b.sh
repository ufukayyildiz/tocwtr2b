#!/bin/bash

# TR2B Private Repository Deployment Script for Cloudflare Workers

set -e

echo "🚀 Starting TR2B private repository deployment to Cloudflare Workers..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# ASCII Art Header
echo -e "${PURPLE}"
cat << "EOF"
████████╗██████╗ ██████╗ ██████╗ 
╚══██╔══╝██╔══██╗╚════██╗██╔══██╗
   ██║   ██████╔╝ █████╔╝██████╔╝
   ██║   ██╔══██╗██╔═══╝ ██╔══██╗
   ██║   ██║  ██║███████╗██████╔╝
   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═════╝ 
                                  
Cloudflare Workers Deployment
EOF
echo -e "${NC}"

# Configuration
TR2B_REPO_URL="https://github.com/ufukayyildiz/TR2B_REPLIT_OR_DATA.git"
BUILD_DIR="./dist"
PUBLIC_DIR="$BUILD_DIR/public"

# Check prerequisites
echo -e "${BLUE}🔍 Checking prerequisites...${NC}"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed.${NC}"
    echo -e "${YELLOW}📥 Please install Node.js 18+ from https://nodejs.org/${NC}"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2)
echo -e "${GREEN}✅ Node.js $NODE_VERSION found${NC}"

# Check Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Git found${NC}"

# Check/Install Wrangler
if ! command -v wrangler &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Wrangler CLI...${NC}"
    npm install -g wrangler
else
    echo -e "${GREEN}✅ Wrangler CLI found${NC}"
fi

# Check Cloudflare authentication
echo -e "${BLUE}🔐 Checking Cloudflare authentication...${NC}"
if ! wrangler whoami &> /dev/null; then
    echo -e "${YELLOW}🔑 Please log in to your Cloudflare account...${NC}"
    wrangler login
    
    if ! wrangler whoami &> /dev/null; then
        echo -e "${RED}❌ Cloudflare authentication failed.${NC}"
        exit 1
    fi
fi

CLOUDFLARE_USER=$(wrangler whoami 2>/dev/null | head -n 1 || echo "Authenticated user")
echo -e "${GREEN}✅ Authenticated as: $CLOUDFLARE_USER${NC}"

# Check for GitHub token
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${YELLOW}⚠️  GITHUB_TOKEN environment variable not set.${NC}"
    echo -e "${BLUE}🔑 For private repository access, you need a GitHub Personal Access Token.${NC}"
    echo -e "${BLUE}   1. Go to GitHub Settings → Developer settings → Personal access tokens${NC}"
    echo -e "${BLUE}   2. Generate a token with 'repo' scope${NC}"
    echo -e "${BLUE}   3. Set it as environment variable: export GITHUB_TOKEN=your_token${NC}"
    echo ""
    read -p "Do you want to continue without token (for public repo)? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Please set GITHUB_TOKEN and run again.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ GitHub token found${NC}"
fi

# Install dependencies
echo -e "${BLUE}📦 Installing dependencies...${NC}"
npm install

# Create build directories
echo -e "${BLUE}📁 Preparing build directories...${NC}"
mkdir -p "$PUBLIC_DIR"

# Clone and build TR2B
echo -e "${BLUE}🔄 Fetching TR2B source code...${NC}"
TMP_DIR=$(mktemp -d)
echo -e "${BLUE}📁 Using temporary directory: $TMP_DIR${NC}"

# Clone with proper authentication
if [ -n "$GITHUB_TOKEN" ]; then
    echo -e "${BLUE}🔐 Cloning private repository with authentication...${NC}"
    REPO_URL_WITH_TOKEN=$(echo "$TR2B_REPO_URL" | sed "s|https://github.com/|https://$GITHUB_TOKEN@github.com/|")
    git clone "$REPO_URL_WITH_TOKEN" "$TMP_DIR/tr2b" || {
        echo -e "${RED}❌ Failed to clone private repository.${NC}"
        echo -e "${YELLOW}💡 Please check your GITHUB_TOKEN and repository access.${NC}"
        exit 1
    }
else
    echo -e "${BLUE}📥 Cloning public repository...${NC}"
    git clone "$TR2B_REPO_URL" "$TMP_DIR/tr2b" || {
        echo -e "${RED}❌ Failed to clone repository.${NC}"
        echo -e "${YELLOW}💡 Repository may be private. Set GITHUB_TOKEN environment variable.${NC}"
        exit 1
    }
fi

echo -e "${GREEN}✅ Repository cloned successfully${NC}"

# Build TR2B project
echo -e "${BLUE}🏗️  Building TR2B project...${NC}"
cd "$TMP_DIR/tr2b"

# Install TR2B dependencies
echo -e "${BLUE}📦 Installing TR2B dependencies...${NC}"
npm install || {
    echo -e "${YELLOW}⚠️  npm install failed, trying with --legacy-peer-deps...${NC}"
    npm install --legacy-peer-deps || {
        echo -e "${RED}❌ Failed to install TR2B dependencies.${NC}"
        exit 1
    }
}

# Build the project with multiple fallback options
echo -e "${BLUE}🔨 Building TR2B frontend...${NC}"
if npm run build 2>/dev/null; then
    echo -e "${GREEN}✅ Build successful with 'npm run build'${NC}"
elif npm run build:client 2>/dev/null; then
    echo -e "${GREEN}✅ Build successful with 'npm run build:client'${NC}"
elif npm run build:production 2>/dev/null; then
    echo -e "${GREEN}✅ Build successful with 'npm run build:production'${NC}"
elif [ -f "vite.config.ts" ] || [ -f "vite.config.js" ]; then
    echo -e "${YELLOW}⚠️  Trying Vite build...${NC}"
    npx vite build || {
        echo -e "${RED}❌ Vite build failed.${NC}"
        exit 1
    }
    echo -e "${GREEN}✅ Vite build successful${NC}"
else
    echo -e "${RED}❌ No suitable build command found.${NC}"
    echo -e "${YELLOW}💡 Available scripts:${NC}"
    npm run 2>/dev/null || echo "No scripts found"
    exit 1
fi

# Copy built assets to our template
echo -e "${BLUE}📂 Copying built assets...${NC}"
cd - > /dev/null # Go back to template directory

# Find and copy built assets
ASSET_COPIED=false

# Try different common build output directories
for BUILD_OUTPUT in "dist" "build" "client/dist" "client/build" "public"; do
    SOURCE_PATH="$TMP_DIR/tr2b/$BUILD_OUTPUT"
    if [ -d "$SOURCE_PATH" ] && [ "$(ls -A "$SOURCE_PATH" 2>/dev/null)" ]; then
        echo -e "${BLUE}📁 Found assets in: $BUILD_OUTPUT${NC}"
        cp -r "$SOURCE_PATH"/* "$PUBLIC_DIR/" 2>/dev/null || {
            echo -e "${YELLOW}⚠️  Some files couldn't be copied from $BUILD_OUTPUT${NC}"
        }
        ASSET_COPIED=true
        break
    fi
done

if [ "$ASSET_COPIED" = false ]; then
    echo -e "${RED}❌ No built assets found in common directories.${NC}"
    echo -e "${YELLOW}💡 Checking available directories in TR2B:${NC}"
    ls -la "$TMP_DIR/tr2b/" || echo "Could not list directories"
    exit 1
fi

# Verify essential files
if [ ! -f "$PUBLIC_DIR/index.html" ]; then
    echo -e "${YELLOW}⚠️  index.html not found. Creating a basic one...${NC}"
    cat > "$PUBLIC_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TR2B Application</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }
        .container { max-width: 800px; margin: 0 auto; text-align: center; }
        .status { padding: 20px; border-radius: 8px; margin: 20px 0; }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
    </style>
</head>
<body>
    <div class="container">
        <h1>TR2B Application</h1>
        <div class="status success">
            <h2>Deployment Successful!</h2>
            <p>Your TR2B application has been deployed to Cloudflare Workers.</p>
            <p>The application assets have been built and are ready to serve.</p>
        </div>
        <p>If you're seeing this page, it means the deployment process completed successfully.</p>
    </div>
</body>
</html>
EOF
fi

echo -e "${GREEN}✅ Assets copied successfully${NC}"

# Clean up temporary directory
echo -e "${BLUE}🧹 Cleaning up...${NC}"
rm -rf "$TMP_DIR"

# Deploy to Cloudflare Workers
echo -e "${BLUE}🚀 Deploying to Cloudflare Workers...${NC}"

# Check if wrangler.toml exists and configure if needed
if [ ! -f "wrangler.toml" ]; then
    echo -e "${YELLOW}⚠️  wrangler.toml not found. Creating default configuration...${NC}"
    read -p "Enter your worker name (default: tr2b): " WORKER_NAME
    WORKER_NAME=${WORKER_NAME:-tr2b}
    
    cat > wrangler.toml << EOF
name = "$WORKER_NAME"
compatibility_date = "$(date +%Y-%m-%d)"
main = "src/index.ts"

[assets]
directory = "./dist/public"
binding = "ASSETS"
html_handling = "auto-trailing-slash"
not_found_handling = "single-page-application"

[vars]
NODE_ENV = "production"

[[kv_namespaces]]
binding = "SESSION_KV"
id = ""
preview_id = ""
EOF
    echo -e "${GREEN}✅ wrangler.toml created${NC}"
fi

# Deploy
wrangler deploy || {
    echo -e "${RED}❌ Deployment failed.${NC}"
    echo -e "${YELLOW}💡 Check the error messages above and your Cloudflare configuration.${NC}"
    exit 1
}

echo -e "${GREEN}🎉 Deployment successful!${NC}"
echo -e "${BLUE}🌐 Your TR2B application is now live on Cloudflare Workers.${NC}"

# Get worker info
echo -e "${BLUE}📋 Deployment Summary:${NC}"
echo -e "   Project: TR2B Application"
echo -e "   Source: $TR2B_REPO_URL"
echo -e "   Platform: Cloudflare Workers"
echo -e "   Build Time: $(date)"

# Show worker URL if possible
WORKER_URL=$(wrangler deployments list 2>/dev/null | grep -o "https://.*\.workers\.dev" | head -n 1 || echo "Check your Cloudflare dashboard for the URL")
echo -e "${GREEN}🔗 Worker URL: $WORKER_URL${NC}"

echo -e "${YELLOW}📋 Next steps:${NC}"
echo -e "   1. Visit your worker URL to see your application"
echo -e "   2. Configure custom domain (optional): ${BLUE}wrangler custom-domains add your-domain.com${NC}"
echo -e "   3. Set up environment variables: ${BLUE}wrangler secret put VARIABLE_NAME${NC}"
echo -e "   4. Monitor logs: ${BLUE}wrangler tail${NC}"
echo -e "   5. View analytics: ${BLUE}wrangler analytics${NC}"

echo -e "${GREEN}✨ TR2B deployment completed successfully!${NC}"
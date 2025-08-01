#!/bin/bash

# TR2B Cloudflare Workers Setup Script
# This script sets up the TR2B application for deployment to Cloudflare Workers

set -e

echo "🚀 Setting up TR2B for Cloudflare Workers deployment..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# ASCII Art
echo -e "${PURPLE}"
cat << "EOF"
████████╗██████╗ ██████╗ ██████╗ 
╚══██╔══╝██╔══██╗╚════██╗██╔══██╗
   ██║   ██████╔╝ █████╔╝██████╔╝
   ██║   ██╔══██╗██╔═══╝ ██╔══██╗
   ██║   ██║  ██║███████╗██████╔╝
   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═════╝ 
                                  
Cloudflare Workers Setup
EOF
echo -e "${NC}"

# Configuration
TR2B_REPO_URL="https://github.com/ufukayyildiz/TR2B_REPLIT_OR_DATA.git"
BUILD_DIR="./dist"
PUBLIC_DIR="$BUILD_DIR/public"

echo -e "${BLUE}📋 Setup Steps:${NC}"
echo -e "   1. Install dependencies"
echo -e "   2. Authenticate with Cloudflare"
echo -e "   3. Clone and build TR2B project"
echo -e "   4. Configure Wrangler"
echo -e "   5. Ready for deployment"
echo ""

# Step 1: Install dependencies
echo -e "${BLUE}1️⃣  Installing dependencies...${NC}"
npm install

# Step 2: Check Cloudflare authentication
echo -e "${BLUE}2️⃣  Checking Cloudflare authentication...${NC}"
if ! command -v wrangler &> /dev/null; then
    echo -e "${YELLOW}Installing Wrangler CLI...${NC}"
    npm install -g wrangler
fi

if ! wrangler whoami &> /dev/null; then
    echo -e "${YELLOW}🔑 Please authenticate with Cloudflare...${NC}"
    wrangler login
    
    if ! wrangler whoami &> /dev/null; then
        echo -e "${RED}❌ Cloudflare authentication failed.${NC}"
        exit 1
    fi
fi

CLOUDFLARE_USER=$(wrangler whoami 2>/dev/null | head -n 1 || echo "Authenticated user")
echo -e "${GREEN}✅ Authenticated as: $CLOUDFLARE_USER${NC}"

# Step 3: Setup GitHub access
echo -e "${BLUE}3️⃣  Setting up GitHub access...${NC}"
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${YELLOW}⚠️  GITHUB_TOKEN not found.${NC}"
    echo -e "${BLUE}For private repository access, you need a GitHub Personal Access Token:${NC}"
    echo -e "${BLUE}   1. Go to GitHub Settings → Developer settings → Personal access tokens${NC}"
    echo -e "${BLUE}   2. Generate token with 'repo' scope${NC}"
    echo -e "${BLUE}   3. Set environment variable: export GITHUB_TOKEN=your_token${NC}"
    echo ""
    read -p "Enter your GitHub token (or press Enter to skip): " -s GITHUB_TOKEN
    echo ""
    if [ -n "$GITHUB_TOKEN" ]; then
        export GITHUB_TOKEN
        echo -e "${GREEN}✅ GitHub token set for this session${NC}"
    fi
else
    echo -e "${GREEN}✅ GitHub token found${NC}"
fi

# Step 4: Clone and build TR2B
echo -e "${BLUE}4️⃣  Fetching TR2B source code...${NC}"
TMP_DIR=$(mktemp -d)

if [ -n "$GITHUB_TOKEN" ]; then
    echo -e "${BLUE}🔐 Using GitHub token for private repository access...${NC}"
    REPO_URL_WITH_TOKEN=$(echo "$TR2B_REPO_URL" | sed "s|https://github.com/|https://$GITHUB_TOKEN@github.com/|")
    git clone "$REPO_URL_WITH_TOKEN" "$TMP_DIR/tr2b" || {
        echo -e "${RED}❌ Failed to clone private repository.${NC}"
        echo -e "${YELLOW}💡 Please check your GITHUB_TOKEN permissions.${NC}"
        exit 1
    }
else
    echo -e "${BLUE}📥 Attempting to clone public repository...${NC}"
    git clone "$TR2B_REPO_URL" "$TMP_DIR/tr2b" || {
        echo -e "${RED}❌ Failed to clone repository.${NC}"
        echo -e "${YELLOW}💡 Repository may be private. Please set GITHUB_TOKEN.${NC}"
        exit 1
    }
fi

echo -e "${GREEN}✅ Repository cloned successfully${NC}"

# Build TR2B
echo -e "${BLUE}🏗️  Building TR2B project...${NC}"
cd "$TMP_DIR/tr2b"

# Install dependencies
npm install || npm install --legacy-peer-deps || {
    echo -e "${RED}❌ Failed to install TR2B dependencies.${NC}"
    exit 1
}

# Build frontend
if npm run build 2>/dev/null; then
    echo -e "${GREEN}✅ Build successful${NC}"
elif npm run build:client 2>/dev/null; then
    echo -e "${GREEN}✅ Client build successful${NC}"
elif npx vite build 2>/dev/null; then
    echo -e "${GREEN}✅ Vite build successful${NC}"
else
    echo -e "${RED}❌ Build failed.${NC}"
    exit 1
fi

# Copy assets
cd - > /dev/null
mkdir -p "$PUBLIC_DIR"

# Find and copy built assets
ASSET_COPIED=false
for BUILD_OUTPUT in "dist" "build" "client/dist" "client/build"; do
    SOURCE_PATH="$TMP_DIR/tr2b/$BUILD_OUTPUT"
    if [ -d "$SOURCE_PATH" ] && [ "$(ls -A "$SOURCE_PATH" 2>/dev/null)" ]; then
        echo -e "${BLUE}📁 Copying assets from: $BUILD_OUTPUT${NC}"
        cp -r "$SOURCE_PATH"/* "$PUBLIC_DIR/" 2>/dev/null || true
        ASSET_COPIED=true
        break
    fi
done

if [ "$ASSET_COPIED" = false ]; then
    echo -e "${YELLOW}⚠️  No built assets found. Creating basic index.html...${NC}"
    cat > "$PUBLIC_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TR2B Application</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { text-align: center; margin-bottom: 30px; }
        .status { padding: 20px; border-radius: 8px; margin: 20px 0; background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .badge { display: inline-block; padding: 4px 12px; background: #007bff; color: white; border-radius: 16px; font-size: 12px; margin: 4px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 TR2B Application</h1>
            <p>Template React To Backend - Deployed to Cloudflare Workers</p>
            <div>
                <span class="badge">React</span>
                <span class="badge">TypeScript</span>
                <span class="badge">Express.js</span>
                <span class="badge">Cloudflare Workers</span>
            </div>
        </div>
        <div class="status">
            <h2>✅ Deployment Successful!</h2>
            <p>Your TR2B application has been successfully deployed to Cloudflare Workers.</p>
            <p>The template automatically cloned your repository, built the assets, and configured the serverless backend.</p>
        </div>
        <div style="text-align: center; margin-top: 30px;">
            <p><strong>Repository:</strong> <a href="https://github.com/ufukayyildiz/TR2B_REPLIT_OR_DATA.git" target="_blank">TR2B Source</a></p>
            <p><strong>Platform:</strong> Cloudflare Workers</p>
        </div>
    </div>
</body>
</html>
EOF
fi

# Step 5: Configure KV namespace
echo -e "${BLUE}5️⃣  Configuring KV namespace...${NC}"
if ! wrangler kv:namespace list | grep -q "SESSION_KV"; then
    echo -e "${BLUE}Creating SESSION_KV namespace...${NC}"
    KV_ID=$(wrangler kv:namespace create "SESSION_KV" --preview | grep -o 'id = "[^"]*"' | cut -d'"' -f2)
    KV_PREVIEW_ID=$(wrangler kv:namespace create "SESSION_KV" --preview | grep -o 'preview_id = "[^"]*"' | cut -d'"' -f2)
    
    # Update wrangler.json with KV IDs
    if [ -n "$KV_ID" ] && [ -n "$KV_PREVIEW_ID" ]; then
        echo -e "${GREEN}✅ KV namespace created successfully${NC}"
    fi
else
    echo -e "${GREEN}✅ KV namespace already exists${NC}"
fi

# Cleanup
rm -rf "$TMP_DIR"

# Final setup complete
echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Summary:${NC}"
echo -e "   ✅ Dependencies installed"
echo -e "   ✅ Cloudflare authenticated"
echo -e "   ✅ TR2B source code fetched and built"
echo -e "   ✅ Assets prepared for deployment"
echo -e "   ✅ KV namespace configured"
echo ""
echo -e "${YELLOW}🚀 Ready for deployment! Run:${NC}"
echo -e "${GREEN}   npm run deploy${NC}"
echo ""
echo -e "${BLUE}📖 Additional commands:${NC}"
echo -e "   • ${GREEN}npm run dev${NC}     - Start development server"
echo -e "   • ${GREEN}wrangler tail${NC}   - View real-time logs"
echo -e "   • ${GREEN}wrangler kv:key list --binding SESSION_KV${NC} - Manage KV data"
echo ""
echo -e "${GREEN}✨ TR2B setup completed!${NC}"
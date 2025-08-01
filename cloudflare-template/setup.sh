#!/bin/bash

# TR2B Cloudflare Workers Setup Script

set -e

echo "🛠️  Setting up TR2B Cloudflare Workers deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check Node.js version
NODE_VERSION=$(node --version | cut -d'v' -f2)
REQUIRED_VERSION="18.0.0"

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed.${NC}"
    echo -e "${YELLOW}📥 Please install Node.js 18+ from https://nodejs.org/${NC}"
    exit 1
fi

# Check if Node.js version is sufficient
if ! npm list semver &> /dev/null; then
    npm install semver
fi

# Install Wrangler CLI if not present
if ! command -v wrangler &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Wrangler CLI...${NC}"
    npm install -g wrangler
else
    echo -e "${GREEN}✅ Wrangler CLI is already installed.${NC}"
fi

# Install project dependencies
echo -e "${BLUE}📦 Installing project dependencies...${NC}"
npm install

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

CLOUDFLARE_USER=$(wrangler whoami | head -n 1)
echo -e "${GREEN}✅ Authenticated as: $CLOUDFLARE_USER${NC}"

# Create wrangler.toml if it doesn't exist
if [ ! -f "wrangler.toml" ]; then
    echo -e "${BLUE}📝 Creating wrangler.toml configuration...${NC}"
    
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

[env.staging]
name = "$WORKER_NAME-staging"
vars = { NODE_ENV = "staging" }
EOF
    
    echo -e "${GREEN}✅ wrangler.toml created successfully.${NC}"
fi

# Create KV namespace for sessions
echo -e "${BLUE}🗄️  Setting up KV namespace for sessions...${NC}"
KV_ID=$(wrangler kv:namespace create "SESSION_KV" | grep -o '"id": "[^"]*"' | cut -d'"' -f4 || echo "")
PREVIEW_KV_ID=$(wrangler kv:namespace create "SESSION_KV" --preview | grep -o '"id": "[^"]*"' | cut -d'"' -f4 || echo "")

if [ -n "$KV_ID" ] && [ -n "$PREVIEW_KV_ID" ]; then
    # Update wrangler.toml with KV namespace IDs
    sed -i.bak "s/id = \"\"/id = \"$KV_ID\"/" wrangler.toml
    sed -i.bak "s/preview_id = \"\"/preview_id = \"$PREVIEW_KV_ID\"/" wrangler.toml
    rm wrangler.toml.bak
    echo -e "${GREEN}✅ KV namespace configured.${NC}"
else
    echo -e "${YELLOW}⚠️  Could not create KV namespace automatically.${NC}"
    echo -e "${YELLOW}   Please create it manually in the Cloudflare dashboard.${NC}"
fi

# Set up environment variables
echo -e "${BLUE}🔧 Setting up environment variables...${NC}"
echo -e "${YELLOW}📝 You can set these later using 'wrangler secret put VARIABLE_NAME':${NC}"
echo -e "   - DATABASE_URL (if using external database)"
echo -e "   - API_KEY (if your app requires API keys)"
echo -e "   - Any other secrets your TR2B app needs"

# Create .env.example file
cat > .env.example << EOF
# Environment variables for TR2B
# Copy this to .env and fill in your values for local development

DATABASE_URL=your_database_url_here
API_KEY=your_api_key_here

# Add other environment variables your TR2B app needs
EOF

echo -e "${GREEN}✅ .env.example created.${NC}"

# Build directory setup
echo -e "${BLUE}📁 Setting up build directories...${NC}"
mkdir -p dist/public
mkdir -p src

# Create a basic index.html for testing
if [ ! -f "dist/public/index.html" ]; then
    cat > dist/public/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TR2B - Loading...</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            height: 100vh; 
            margin: 0; 
            background: #f0f0f0; 
        }
        .loader { text-align: center; }
        .spinner { 
            border: 4px solid #f3f3f3; 
            border-top: 4px solid #3498db; 
            border-radius: 50%; 
            width: 40px; 
            height: 40px; 
            animation: spin 2s linear infinite; 
            margin: 0 auto 20px; 
        }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
    </style>
</head>
<body>
    <div class="loader">
        <div class="spinner"></div>
        <h2>TR2B</h2>
        <p>Setting up your application...</p>
        <p><small>This placeholder will be replaced when you deploy your TR2B app.</small></p>
    </div>
</body>
</html>
EOF
fi

echo -e "${GREEN}🎉 Setup complete!${NC}"
echo -e "${BLUE}📋 Next steps:${NC}"
echo -e "   1. Run ${YELLOW}'npm run deploy'${NC} to deploy your worker"
echo -e "   2. Configure your TR2B source repository URL"
echo -e "   3. Run the deployment script to build and deploy TR2B"
echo -e "   4. Set up your custom domain (optional)"

echo -e "${YELLOW}💡 Useful commands:${NC}"
echo -e "   - ${BLUE}npm run dev${NC}     # Start local development server"
echo -e "   - ${BLUE}npm run deploy${NC}  # Deploy to Cloudflare Workers"
echo -e "   - ${BLUE}npm run tail${NC}    # View worker logs"
echo -e "   - ${BLUE}./deploy.sh${NC}     # Full deployment pipeline"

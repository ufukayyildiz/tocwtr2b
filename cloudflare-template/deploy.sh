#!/bin/bash

# TR2B Cloudflare Workers Deployment Script

set -e

echo "🚀 Starting TR2B deployment to Cloudflare Workers..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo -e "${RED}❌ Wrangler CLI is not installed.${NC}"
    echo -e "${YELLOW}📦 Installing Wrangler...${NC}"
    npm install -g wrangler
fi

# Check if user is logged in
if ! wrangler whoami &> /dev/null; then
    echo -e "${YELLOW}🔐 Please log in to Cloudflare...${NC}"
    wrangler login
fi

# Install dependencies
echo -e "${BLUE}📦 Installing dependencies...${NC}"
npm install

# Clone and build TR2B project
echo -e "${BLUE}🔄 Fetching latest TR2B code...${NC}"

# Create a temporary directory for the TR2B project
TMP_DIR=$(mktemp -d)
echo -e "${BLUE}📁 Using temporary directory: $TMP_DIR${NC}"

# Since the Replit link isn't directly clonable, we'll need to handle this differently
# For now, we'll assume the user has provided the correct GitHub repository
# You may need to update this URL to the actual GitHub repository

if [ -z "$TR2B_REPO_URL" ]; then
    echo -e "${YELLOW}⚠️  TR2B_REPO_URL not set. Using default...${NC}"
    TR2B_REPO_URL="https://github.com/YOUR_USERNAME/TR2B.git"
fi

echo -e "${BLUE}📥 Cloning TR2B from: $TR2B_REPO_URL${NC}"
git clone "$TR2B_REPO_URL" "$TMP_DIR/tr2b" || {
    echo -e "${RED}❌ Failed to clone TR2B repository.${NC}"
    echo -e "${YELLOW}💡 Please ensure TR2B_REPO_URL is set correctly.${NC}"
    exit 1
}

# Build the frontend
echo -e "${BLUE}🏗️  Building TR2B frontend...${NC}"
cd "$TMP_DIR/tr2b"

# Install TR2B dependencies
npm install

# Build the project
npm run build || {
    echo -e "${YELLOW}⚠️  Standard build failed, trying alternative build command...${NC}"
    npm run build:client || {
        echo -e "${RED}❌ Failed to build TR2B frontend.${NC}"
        exit 1
    }
}

# Copy built assets to our template
echo -e "${BLUE}📂 Copying built assets...${NC}"
cd - # Go back to the template directory

# Create dist directory if it doesn't exist
mkdir -p dist/public

# Copy the built frontend to our dist directory
if [ -d "$TMP_DIR/tr2b/dist" ]; then
    cp -r "$TMP_DIR/tr2b/dist"/* dist/public/
elif [ -d "$TMP_DIR/tr2b/build" ]; then
    cp -r "$TMP_DIR/tr2b/build"/* dist/public/
elif [ -d "$TMP_DIR/tr2b/client/dist" ]; then
    cp -r "$TMP_DIR/tr2b/client/dist"/* dist/public/
else
    echo -e "${RED}❌ Could not find built frontend assets.${NC}"
    echo -e "${YELLOW}💡 Please check the TR2B build output directory.${NC}"
    exit 1
fi

# Ensure index.html exists
if [ ! -f "dist/public/index.html" ]; then
    echo -e "${RED}❌ index.html not found in built assets.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Assets copied successfully.${NC}"

# Clean up temporary directory
rm -rf "$TMP_DIR"

# Deploy to Cloudflare Workers
echo -e "${BLUE}🚀 Deploying to Cloudflare Workers...${NC}"
wrangler deploy

echo -e "${GREEN}🎉 Deployment successful!${NC}"
echo -e "${BLUE}🌐 Your TR2B app is now live on Cloudflare Workers.${NC}"

# Show worker URL
WORKER_URL=$(wrangler whoami 2>/dev/null | grep -o "https://.*\.workers\.dev" || echo "Check your Cloudflare dashboard for the URL")
echo -e "${GREEN}🔗 Worker URL: $WORKER_URL${NC}"

echo -e "${YELLOW}📋 Next steps:${NC}"
echo -e "   1. Configure your custom domain (optional)"
echo -e "   2. Set up environment variables if needed"
echo -e "   3. Monitor your worker in the Cloudflare dashboard"

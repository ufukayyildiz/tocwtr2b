#!/bin/bash

# TR2B Deployment Validation Script

set -e

echo "🔍 Validating TR2B deployment..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get worker URL
WORKER_URL=""
if command -v wrangler &> /dev/null; then
    WORKER_URL=$(wrangler deployments list 2>/dev/null | grep -o "https://.*\.workers\.dev" | head -n 1)
fi

if [ -z "$WORKER_URL" ]; then
    echo -e "${YELLOW}⚠️  Could not determine worker URL automatically.${NC}"
    read -p "Enter your worker URL: " WORKER_URL
fi

echo -e "${BLUE}🌐 Testing worker: $WORKER_URL${NC}"

# Test health endpoint
echo -e "${BLUE}🏥 Checking health endpoint...${NC}"
HEALTH_RESPONSE=$(curl -s -w "%{http_code}" "$WORKER_URL/health" -o /tmp/health_response 2>/dev/null || echo "000")

if [ "$HEALTH_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Health check passed${NC}"
    cat /tmp/health_response | jq '.' 2>/dev/null || cat /tmp/health_response
else
    echo -e "${RED}❌ Health check failed (HTTP $HEALTH_RESPONSE)${NC}"
fi

# Test main page
echo -e "${BLUE}🏠 Checking main page...${NC}"
MAIN_RESPONSE=$(curl -s -w "%{http_code}" "$WORKER_URL/" -o /tmp/main_response 2>/dev/null || echo "000")

if [ "$MAIN_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Main page accessible${NC}"
    
    # Check if it's HTML
    if grep -q "<!DOCTYPE html" /tmp/main_response; then
        echo -e "${GREEN}✅ HTML content detected${NC}"
        
        # Look for TR2B indicators
        if grep -qi "tr2b\|react\|vite" /tmp/main_response; then
            echo -e "${GREEN}✅ TR2B application detected${NC}"
        else
            echo -e "${YELLOW}⚠️  TR2B indicators not found in HTML${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Non-HTML content returned${NC}"
    fi
else
    echo -e "${RED}❌ Main page failed (HTTP $MAIN_RESPONSE)${NC}"
fi

# Test API endpoints
echo -e "${BLUE}🔌 Checking API endpoints...${NC}"
API_RESPONSE=$(curl -s -w "%{http_code}" "$WORKER_URL/api/env" -o /tmp/api_response 2>/dev/null || echo "000")

if [ "$API_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ API endpoints working${NC}"
    cat /tmp/api_response | jq '.' 2>/dev/null || cat /tmp/api_response
else
    echo -e "${YELLOW}⚠️  API endpoints may not be working (HTTP $API_RESPONSE)${NC}"
fi

# Test static assets
echo -e "${BLUE}📁 Checking static assets...${NC}"
ASSET_PATHS=("/assets/index.css" "/assets/index.js" "/favicon.ico")

for path in "${ASSET_PATHS[@]}"; do
    ASSET_RESPONSE=$(curl -s -w "%{http_code}" "$WORKER_URL$path" -o /dev/null 2>/dev/null || echo "000")
    if [ "$ASSET_RESPONSE" = "200" ]; then
        echo -e "${GREEN}✅ Asset found: $path${NC}"
    else
        echo -e "${YELLOW}⚠️  Asset not found: $path (HTTP $ASSET_RESPONSE)${NC}"
    fi
done

# Performance test
echo -e "${BLUE}⚡ Performance test...${NC}"
RESPONSE_TIME=$(curl -s -w "%{time_total}" "$WORKER_URL/health" -o /dev/null 2>/dev/null || echo "0")
if (( $(echo "$RESPONSE_TIME < 1.0" | bc -l) )); then
    echo -e "${GREEN}✅ Response time: ${RESPONSE_TIME}s (Good)${NC}"
elif (( $(echo "$RESPONSE_TIME < 3.0" | bc -l) )); then
    echo -e "${YELLOW}⚠️  Response time: ${RESPONSE_TIME}s (Acceptable)${NC}"
else
    echo -e "${RED}❌ Response time: ${RESPONSE_TIME}s (Slow)${NC}"
fi

# Summary
echo -e "${BLUE}📋 Validation Summary:${NC}"
echo -e "   Worker URL: $WORKER_URL"
echo -e "   Health Check: $([ "$HEALTH_RESPONSE" = "200" ] && echo "✅ Pass" || echo "❌ Fail")"
echo -e "   Main Page: $([ "$MAIN_RESPONSE" = "200" ] && echo "✅ Pass" || echo "❌ Fail")"
echo -e "   API Endpoints: $([ "$API_RESPONSE" = "200" ] && echo "✅ Pass" || echo "⚠️ Warning")"
echo -e "   Response Time: ${RESPONSE_TIME}s"

# Cleanup
rm -f /tmp/health_response /tmp/main_response /tmp/api_response

if [ "$HEALTH_RESPONSE" = "200" ] && [ "$MAIN_RESPONSE" = "200" ]; then
    echo -e "${GREEN}🎉 Deployment validation successful!${NC}"
    exit 0
else
    echo -e "${RED}❌ Deployment validation failed. Check the issues above.${NC}"
    exit 1
fi
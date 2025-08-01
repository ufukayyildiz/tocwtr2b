# Complete TR2B Cloudflare Workers Deployment Guide

This comprehensive guide walks you through deploying the TR2B application from the private repository `https://github.com/ufukayyildiz/TR2B_REPLIT_OR_DATA.git` to Cloudflare Workers.

## Quick Start (1-Command Deployment)

```bash
export GITHUB_TOKEN="your_github_token_here" && ./deploy-tr2b.sh
```

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setup GitHub Access](#setup-github-access)
3. [Deployment Methods](#deployment-methods)
4. [Configuration](#configuration)
5. [Troubleshooting](#troubleshooting)
6. [Advanced Usage](#advanced-usage)

## Prerequisites

### Required Software
- **Node.js 18+**: [Download from nodejs.org](https://nodejs.org/)
- **Git**: For repository cloning
- **Cloudflare Account**: [Sign up at workers.dev](https://workers.dev)

### Required Accounts & Tokens
- **GitHub Personal Access Token**: For private repository access
- **Cloudflare API Token**: For Workers deployment

## Setup GitHub Access

### 1. Create GitHub Personal Access Token

1. Go to **GitHub Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **"Generate new token (classic)"**
3. Configure token:
   - **Note**: "TR2B Cloudflare Deployment"
   - **Expiration**: 90 days (or as needed)
   - **Scopes**: Check `repo` (Full control of private repositories)
4. Click **"Generate token"**
5. **Copy the token immediately** (you won't see it again)

### 2. Set Environment Variable

```bash
# For current session
export GITHUB_TOKEN="ghp_your_token_here"

# For permanent setup (add to ~/.bashrc or ~/.zshrc)
echo 'export GITHUB_TOKEN="ghp_your_token_here"' >> ~/.bashrc
source ~/.bashrc
```

## Deployment Methods

### Method 1: Automated Script (Recommended)

The fastest way to deploy:

```bash
# Clone template
git clone https://github.com/YOUR_USERNAME/TR2B-cloudflare-template.git
cd TR2B-cloudflare-template

# Set GitHub token
export GITHUB_TOKEN="your_token_here"

# Run complete deployment
./deploy-tr2b.sh
```

This script:
- ✅ Verifies all prerequisites
- ✅ Authenticates with Cloudflare
- ✅ Clones your private TR2B repository
- ✅ Builds the frontend application
- ✅ Copies assets to Workers format
- ✅ Deploys to Cloudflare Workers
- ✅ Provides deployment URL

### Method 2: GitHub Actions (CI/CD)

Set up automated deployments:

1. **Fork this template repository**
2. **Add repository secrets**:
   - Go to **Settings** → **Secrets and variables** → **Actions**
   - Add:
     ```
     CLOUDFLARE_API_TOKEN: your_cloudflare_api_token
     GITHUB_TOKEN: your_github_personal_access_token
     ```
3. **Push to main branch** to trigger deployment

### Method 3: Step-by-Step Manual

```bash
# 1. Clone and setup
git clone https://github.com/YOUR_USERNAME/TR2B-cloudflare-template.git
cd TR2B-cloudflare-template
npm install

# 2. Authenticate with Cloudflare
npx wrangler login

# 3. Set secrets
npx wrangler secret put GITHUB_TOKEN
# Enter your token when prompted

# 4. Deploy
./deploy.sh
```

## Configuration

### Environment Variables

```bash
# Required for private repository
GITHUB_TOKEN="ghp_your_github_token"

# Required for deployment
CLOUDFLARE_API_TOKEN="your_cloudflare_api_token"

# Optional: Custom repository URL
TR2B_REPO_URL="https://github.com/ufukayyildiz/TR2B_REPLIT_OR_DATA.git"

# Optional: Application configuration
DATABASE_URL="your_database_connection_string"
API_KEY="your_api_key"
```

### Cloudflare Workers Configuration

The deployment creates these configurations:

```toml
# wrangler.toml
name = "tr2b"
compatibility_date = "2024-11-06"
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
id = "auto-generated"
preview_id = "auto-generated"
```

## Troubleshooting

### Common Issues & Solutions

#### 1. Authentication Failed
```
Error: Authentication failed for 'https://github.com/...'
```
**Solution**: 
- Verify your GitHub token has `repo` scope
- Check token hasn't expired
- Ensure you have access to the repository

#### 2. Build Failed
```
Error: Failed to build TR2B frontend
```
**Solutions**:
- Check if TR2B repository has valid package.json
- Verify all dependencies are available
- Try running build locally first

#### 3. Deployment Failed
```
Error: Deployment failed
```
**Solutions**:
- Verify Cloudflare authentication: `wrangler whoami`
- Check account limits and quotas
- Ensure worker name is unique

#### 4. Assets Not Found
```
Error: No built assets found
```
**Solutions**:
- Check TR2B build output directory
- Verify build process completed successfully
- Look for common output directories: `dist`, `build`, `client/dist`

### Debug Commands

```bash
# Check Cloudflare authentication
wrangler whoami

# Test GitHub repository access
git clone https://$GITHUB_TOKEN@github.com/ufukayyildiz/TR2B_REPLIT_OR_DATA.git /tmp/test-clone

# View deployment logs
wrangler tail

# List deployments
wrangler deployments list

# Check worker status
curl https://your-worker.workers.dev/health
```

## Advanced Usage

### Custom Domain Setup

```bash
# Add custom domain
wrangler custom-domains add your-domain.com

# Configure DNS (in Cloudflare dashboard)
# Add CNAME record: your-domain.com → your-worker.workers.dev
```

### Environment-Specific Deployments

```bash
# Deploy to staging
wrangler deploy --env staging

# Deploy to production
wrangler deploy --env production
```

### Monitoring & Analytics

```bash
# Real-time logs
wrangler tail

# View analytics
wrangler analytics

# Check deployment status
wrangler deployments list
```

### Local Development

```bash
# Start local development server
wrangler dev

# Test with local assets
wrangler dev --local
```

## Security Best Practices

1. **Token Management**
   - Rotate GitHub tokens regularly
   - Use separate tokens for different environments
   - Never commit tokens to repository

2. **Secrets Management**
   - Use Cloudflare Workers secrets for sensitive data
   - Don't expose secrets in logs or client-side code
   - Regularly audit secret access

3. **Access Control**
   - Limit GitHub token scope to minimum required
   - Use separate Cloudflare accounts for production
   - Monitor deployment logs for unauthorized access

## Support & Resources

- **TR2B Repository**: https://github.com/ufukayyildiz/TR2B_REPLIT_OR_DATA.git
- **Cloudflare Workers Docs**: https://developers.cloudflare.com/workers/
- **GitHub Tokens Guide**: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
- **Wrangler CLI Docs**: https://developers.cloudflare.com/workers/wrangler/

## Example Deployment Output

```
🚀 Starting TR2B private repository deployment to Cloudflare Workers...
✅ Node.js 18.17.0 found
✅ Git found
✅ Wrangler CLI found
✅ Authenticated as: your-email@example.com
✅ GitHub token found
📦 Installing dependencies...
🔐 Cloning private repository with authentication...
✅ Repository cloned successfully
📦 Installing TR2B dependencies...
🔨 Building TR2B frontend...
✅ Build successful with 'npm run build'
📂 Copying built assets...
✅ Assets copied successfully
🧹 Cleaning up...
🚀 Deploying to Cloudflare Workers...
✅ Deployment successful!
🌐 Your TR2B application is now live on Cloudflare Workers.
🔗 Worker URL: https://tr2b.your-subdomain.workers.dev
```
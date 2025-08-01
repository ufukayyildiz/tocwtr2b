# Deploying Private TR2B Repository to Cloudflare Workers

This guide explains how to deploy your private TR2B repository to Cloudflare Workers.

## Prerequisites

1. **Cloudflare Account**: Sign up at [workers.dev](https://workers.dev)
2. **GitHub Personal Access Token**: Required for private repository access
3. **Wrangler CLI**: Install with `npm install -g wrangler`

## Setting Up GitHub Access

### 1. Create GitHub Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Select scopes:
   - `repo` (Full control of private repositories)
   - `workflow` (Update GitHub Actions workflows)
4. Copy the generated token

### 2. Configure Token for Cloudflare

Set your GitHub token as a Cloudflare Workers secret:

```bash
wrangler secret put GITHUB_TOKEN
# Enter your GitHub token when prompted
```

## Deployment Methods

### Method 1: Direct Deployment Script

```bash
# Set environment variable (for this session)
export GITHUB_TOKEN="your_github_token_here"
export TR2B_REPO_URL="https://github.com/ufukayyildiz/TR2B_REPLIT_OR_DATA.git"

# Run deployment
./deploy.sh
```

### Method 2: GitHub Actions (Recommended)

1. **Fork this template repository**
2. **Add secrets to your repository**:
   - Go to Settings → Secrets and variables → Actions
   - Add these secrets:
     - `CLOUDFLARE_API_TOKEN`: Your Cloudflare API token
     - `GITHUB_TOKEN`: Your GitHub personal access token (if different from default)

3. **Configure repository variables** (optional):
   - Add variable `TR2B_REPO_URL` with value: `https://github.com/ufukayyildiz/TR2B_REPLIT_OR_DATA.git`

4. **Trigger deployment**:
   - Push to `main` branch for production deployment
   - Create PR for staging deployment

### Method 3: Manual Setup

```bash
# Clone this template
git clone https://github.com/YOUR_USERNAME/TR2B-cloudflare-template.git
cd TR2B-cloudflare-template

# Install dependencies
npm install

# Login to Cloudflare
wrangler login

# Set secrets
wrangler secret put GITHUB_TOKEN
wrangler secret put CLOUDFLARE_API_TOKEN

# Deploy
npm run deploy
```

## Environment Configuration

### Required Environment Variables

```bash
# Core secrets
GITHUB_TOKEN=your_github_personal_access_token
CLOUDFLARE_API_TOKEN=your_cloudflare_api_token

# Optional configuration
TR2B_REPO_URL=https://github.com/ufukayyildiz/TR2B_REPLIT_OR_DATA.git
NODE_ENV=production
```

### Setting Up Cloudflare API Token

1. Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Click "Create Token"
3. Use "Custom token" template
4. Configure permissions:
   - Zone:Zone:Read (for your domain)
   - Zone:Zone Settings:Edit (for your domain)
   - Account:Cloudflare Workers:Edit (for your account)
5. Copy the generated token

## Troubleshooting

### Authentication Issues

```bash
# Test GitHub access
git clone https://GITHUB_TOKEN@github.com/ufukayyildiz/TR2B_REPLIT_OR_DATA.git /tmp/test

# Test Cloudflare authentication
wrangler whoami
```

### Build Issues

```bash
# Check build logs
wrangler tail

# Local development
npm run dev
```

### Common Problems

1. **"Authentication failed"**: Check your GitHub token permissions
2. **"Repository not found"**: Verify repository URL and access permissions
3. **"Build failed"**: Check TR2B project dependencies and build scripts
4. **"Deployment failed"**: Verify Cloudflare API token and account permissions

## Security Best Practices

1. **Never commit tokens to Git**
2. **Use environment-specific tokens**
3. **Regularly rotate access tokens**
4. **Monitor deployment logs for sensitive data**
5. **Use Cloudflare secrets for production values**

## Monitoring Your Deployment

```bash
# View real-time logs
wrangler tail

# Check deployment status
wrangler deployments list

# View analytics
wrangler analytics
```

## Custom Domain Setup

1. Add your domain to Cloudflare
2. Configure Workers Custom Domain:
   ```bash
   wrangler custom-domains add your-domain.com
   ```

## Support

For issues specific to:
- **TR2B Application**: Check the original repository documentation
- **Cloudflare Workers**: Visit [Cloudflare Workers docs](https://developers.cloudflare.com/workers/)
- **GitHub Access**: Check [GitHub token documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
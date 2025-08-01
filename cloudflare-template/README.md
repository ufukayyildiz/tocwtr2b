# TR2B Cloudflare Workers Deployment Template

This template provides automated deployment of the TR2B project (https://github.com/ufukayyildiz/TR2B_REPLIT_OR_DATA.git) to Cloudflare Workers with full support for private repositories.

[![Deploy to Cloudflare Workers](https://deploy.workers.cloudflare.com/button)](https://deploy.workers.cloudflare.com/?url=https://github.com/YOUR_USERNAME/TR2B-cloudflare-template)

## About TR2B

TR2B (Template React To Backend) is a full-stack web application built with:
- **Frontend**: React with TypeScript, Vite build system, Tailwind CSS
- **Backend**: Express.js with TypeScript, Drizzle ORM, PostgreSQL support
- **Architecture**: Component-based UI system with shadcn/ui components

This template automatically adapts TR2B to run on Cloudflare Workers with optimized static asset serving and serverless backend functionality.

## Quick Deployment

### Method 1: Automated Script (Recommended for Private Repo)

The easiest way to deploy your private TR2B repository:

```bash
# Clone this template
git clone https://github.com/YOUR_USERNAME/TR2B-cloudflare-template.git
cd TR2B-cloudflare-template

# Set your GitHub token for private repo access
export GITHUB_TOKEN="your_github_personal_access_token"

# Run the automated deployment script
./deploy-tr2b.sh
```

### Method 2: One-Click Deploy (For Public Repos)

1. Click the "Deploy to Cloudflare Workers" button above
2. Follow the Cloudflare dashboard setup
3. Configure your environment variables
4. Deploy!

### Method 3: Manual Step-by-Step

1. **Prerequisites**
   - Node.js 18+ installed
   - Cloudflare account with Wrangler CLI: `npm install -g wrangler`
   - GitHub Personal Access Token (for private repositories)

2. **Setup**
   ```bash
   git clone https://github.com/YOUR_USERNAME/TR2B-cloudflare-template.git
   cd TR2B-cloudflare-template
   npm install
   wrangler login
   ```

3. **Configure Secrets**
   ```bash
   # Required for private repository access
   wrangler secret put GITHUB_TOKEN
   
   # Optional: Set other environment variables
   wrangler secret put DATABASE_URL
   wrangler secret put API_KEY
   ```

4. **Deploy**
   ```bash
   ./deploy.sh  # Uses the repository-aware deployment script
   # OR
   npm run deploy  # Basic deployment
   ```

## Configuration

### Environment Variables

Set these in your Cloudflare Workers dashboard or via `wrangler secret put`:

```bash
# Database (if using external database)
wrangler secret put DATABASE_URL

# GitHub Token (for private repository access)
wrangler secret put GITHUB_TOKEN

# API Keys (add any required for your TR2B app)
wrangler secret put API_KEY

# Database URL (if using external database) 
wrangler secret put DATABASE_URL

# Cloudflare API Token (for automated deployments)
wrangler secret put CLOUDFLARE_API_TOKEN

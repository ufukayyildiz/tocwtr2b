# TR2B Full-Stack App

[![Deploy to Cloudflare Workers](https://deploy.workers.cloudflare.com/button)](https://deploy.workers.cloudflare.com/?url=https://github.com/YOUR_USERNAME/TR2B-cloudflare-template)

![TR2B Application Preview](https://via.placeholder.com/600x400/3498db/ffffff?text=TR2B+Application)

Deploy TR2B (Template React To Backend) full-stack application to Cloudflare Workers with one-click deployment.

## About TR2B

TR2B (Template React To Backend) is a full-stack web application featuring:

- **🚀 Modern Stack**: React + TypeScript + Express.js
- **⚡ Edge Computing**: Optimized for Cloudflare Workers
- **🎨 Beautiful UI**: Shadcn/ui components with Tailwind CSS
- **💾 Data Storage**: Cloudflare KV for session management
- **🔧 Developer Experience**: Hot reload, TypeScript, modern tooling

This template automatically clones your TR2B repository, builds the frontend, adapts the backend for serverless, and deploys everything to Cloudflare's global edge network.

## Getting Started

Outside of this repo, you can start a new project with this template using [C3](https://developers.cloudflare.com/pages/get-started/c3/) (the `create-cloudflare` CLI):

```bash
npm create cloudflare@latest -- --template=YOUR_USERNAME/TR2B-cloudflare-template
```

**Important**: When using C3 to create this project, select "no" when it asks if you want to deploy. You need to follow this project's setup steps before deploying.

## Setup Steps

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Authenticate with Cloudflare**
   ```bash
   npx wrangler login
   ```

3. **Set up GitHub access** (for private repository)
   ```bash
   # Set your GitHub Personal Access Token
   export GITHUB_TOKEN="your_github_token_here"
   ```

4. **Run setup script**
   ```bash
   npm run setup
   ```

5. **Deploy**
   ```bash
   npm run deploy
   ```

## Key Features

- **🔒 Private Repository Support**: Automatic authentication and cloning of private TR2B repositories
- **⚡ Edge-First**: Optimized for Cloudflare Workers with global edge deployment
- **📁 Asset Management**: Automatic frontend build and static asset serving
- **💾 KV Storage**: Session management using Cloudflare KV
- **🔧 Zero Configuration**: Automatic setup of all required Cloudflare resources
- **🚀 One-Click Deploy**: Complete deployment with a single command

## Next Steps

By default, this template:

1. **Clones your TR2B repository** from the private GitHub repository
2. **Builds the React frontend** using the existing build configuration
3. **Adapts the Express backend** to run on Cloudflare Workers using Hono
4. **Sets up KV storage** for session management and data persistence
5. **Configures asset serving** for optimal performance on the edge

After deployment, you can:

- **Monitor your application**: `wrangler tail` for real-time logs
- **Manage KV data**: `wrangler kv:key list --binding SESSION_KV`
- **Update your app**: Redeploy with `npm run deploy`
- **Scale globally**: Your app runs on Cloudflare's global edge network

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

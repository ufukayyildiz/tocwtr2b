# TR2B Cloudflare Workers Deployment Template

This template provides one-click deployment of the TR2B project to Cloudflare Workers.

[![Deploy to Cloudflare Workers](https://deploy.workers.cloudflare.com/button)](https://deploy.workers.cloudflare.com/?url=https://github.com/YOUR_USERNAME/TR2B-cloudflare-template)

## About TR2B

TR2B is a full-stack web application built with React frontend and Express.js backend. This template adapts it to run on Cloudflare Workers with static asset serving.

## Quick Deployment

### Method 1: One-Click Deploy (Recommended)

1. Click the "Deploy to Cloudflare Workers" button above
2. Follow the Cloudflare dashboard setup
3. Configure your environment variables
4. Deploy!

### Method 2: Manual Setup

1. **Prerequisites**
   - Node.js 18+ installed
   - Cloudflare account
   - Wrangler CLI installed: `npm install -g wrangler`

2. **Clone and Setup**
   ```bash
   git clone https://github.com/YOUR_USERNAME/TR2B-cloudflare-template.git
   cd TR2B-cloudflare-template
   npm install
   ```

3. **Configure Wrangler**
   ```bash
   wrangler login
   ```

4. **Deploy**
   ```bash
   npm run deploy
   ```

## Configuration

### Environment Variables

Set these in your Cloudflare Workers dashboard or via `wrangler secret put`:

```bash
# Database (if using external database)
wrangler secret put DATABASE_URL

# API Keys (add any required for your TR2B app)
wrangler secret put API_KEY

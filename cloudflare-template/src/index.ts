import { Hono } from 'hono'
import type { Context } from 'hono'

type Bindings = {
  NODE_ENV?: string
}

type Variables = {}

type HonoEnv = {
  Bindings: Bindings
  Variables: Variables
}

const app = new Hono<HonoEnv>()

// Health check endpoint
app.get('/api/health', (c: Context<HonoEnv>) => {
  return c.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    environment: 'production',
    platform: 'Cloudflare Workers',
    message: 'TR2B application running on the edge'
  })
})

// Environment info endpoint  
app.get('/api/env', (c: Context<HonoEnv>) => {
  return c.json({
    platform: 'Cloudflare Workers',
    timestamp: new Date().toISOString(),
    environment: 'production',
    tr2b: 'Template React To Backend',
    edge: true,
    region: c.req.cf?.colo || 'unknown'
  })
})

// Demo data endpoint adapted from TR2B
app.get('/api/data', (c: Context<HonoEnv>) => {
  return c.json({
    message: 'TR2B API running on Cloudflare Workers edge network',
    data: [
      { id: 1, name: 'Edge Demo Item 1', type: 'serverless', location: c.req.cf?.colo || 'edge' },
      { id: 2, name: 'Edge Demo Item 2', type: 'serverless', location: c.req.cf?.colo || 'edge' },
      { id: 3, name: 'Edge Demo Item 3', type: 'serverless', location: c.req.cf?.colo || 'edge' }
    ],
    total: 3,
    timestamp: new Date().toISOString(),
    edgeLocation: c.req.cf?.colo,
    country: c.req.cf?.country
  })
})

// Session demo endpoint (in-memory for template demonstration)
app.get('/api/session', (c: Context<HonoEnv>) => {
  const sessionId = globalThis.crypto.randomUUID()
  const sessionData = {
    id: sessionId,
    created: new Date().toISOString(),
    platform: 'Cloudflare Workers',
    tr2b: true,
    edge: true,
    location: c.req.cf?.colo
  }
  
  return c.json({
    message: 'Session demo created (configure KV storage for persistence)',
    session: sessionData,
    note: 'Add KV namespace binding to wrangler.json for persistent sessions'
  })
})

// User management endpoints (adapted from TR2B Express routes)
interface User {
  id: string
  username: string
  email: string
  createdAt: string
  platform: string
}

const users = new Map<string, User>()

app.get('/api/users', (c: Context<HonoEnv>) => {
  return c.json({
    users: Array.from(users.values()),
    total: users.size,
    platform: 'Cloudflare Workers'
  })
})

app.post('/api/users', async (c: Context<HonoEnv>) => {
  const { username, email } = await c.req.json()
  
  if (!username || !email) {
    return c.json({ error: 'Username and email are required' }, 400)
  }
  
  const id = globalThis.crypto.randomUUID()
  const user: User = { 
    id, 
    username, 
    email, 
    createdAt: new Date().toISOString(),
    platform: 'Cloudflare Workers'
  }
  users.set(id, user)
  
  return c.json(user, 201)
})

// Serve static assets from TR2B build
app.get('/*', (c: Context<HonoEnv>) => {
  // For API routes, return 404
  if (c.req.path.startsWith('/api/')) {
    return c.json({ error: 'Not Found', path: c.req.path }, 404)
  }
  
  // For frontend routes, return basic HTML for now
  return c.html(`
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
            .api-demo { margin-top: 30px; }
            .endpoint { background: #f8f9fa; padding: 15px; margin: 10px 0; border-radius: 4px; border-left: 4px solid #007bff; }
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
                <p>Your TR2B application template has been successfully deployed to Cloudflare Workers.</p>
                <p>The setup script will automatically clone your repository, build the assets, and configure the serverless backend.</p>
            </div>
            <div class="api-demo">
                <h3>API Endpoints Available:</h3>
                <div class="endpoint">
                    <strong>GET /api/health</strong> - Health check endpoint
                </div>
                <div class="endpoint">
                    <strong>GET /api/env</strong> - Environment information
                </div>
                <div class="endpoint">
                    <strong>GET /api/data</strong> - Demo data endpoint
                </div>
                <div class="endpoint">
                    <strong>GET /api/session</strong> - Session demo endpoint
                </div>
                <div class="endpoint">
                    <strong>GET /api/users</strong> - User management endpoint
                </div>
            </div>
            <div style="text-align: center; margin-top: 30px;">
                <p><strong>Repository:</strong> <a href="https://github.com/ufukayyildiz/TR2B_REPLIT_OR_DATA.git" target="_blank">TR2B Source</a></p>
                <p><strong>Platform:</strong> Cloudflare Workers</p>
                <p><strong>Edge Location:</strong> Global</p>
            </div>
        </div>
        <script>
            // Test API endpoints
            fetch('/api/env')
                .then(response => response.json())
                .then(data => console.log('Environment:', data))
                .catch(error => console.error('API Error:', error));
        </script>
    </body>
    </html>
  `)
})

export default app
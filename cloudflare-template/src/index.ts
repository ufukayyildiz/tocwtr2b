import { Hono } from 'hono'
import { serveStatic } from 'hono/cloudflare-workers'

type Bindings = {
  ASSETS: Fetcher
  SESSION_KV: KVNamespace
}

const app = new Hono<{ Bindings: Bindings }>()

// Health check endpoint
app.get('/api/health', (c) => {
  return c.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    environment: 'production',
    platform: 'Cloudflare Workers',
    message: 'TR2B application running on the edge'
  })
})

// Environment info endpoint  
app.get('/api/env', (c) => {
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
app.get('/api/data', (c) => {
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

// Session management using Cloudflare KV (replaces Express session)
app.get('/api/session', async (c) => {
  const sessionId = crypto.randomUUID()
  const sessionData = {
    id: sessionId,
    created: new Date().toISOString(),
    platform: 'Cloudflare Workers',
    tr2b: true,
    edge: true,
    location: c.req.cf?.colo
  }
  
  await c.env.SESSION_KV.put(`session:${sessionId}`, JSON.stringify(sessionData), {
    expirationTtl: 3600 // 1 hour TTL
  })
  
  return c.json({
    message: 'Session created in Cloudflare KV',
    session: sessionData
  })
})

// Retrieve session from KV
app.get('/api/session/:id', async (c) => {
  const sessionId = c.req.param('id')
  const sessionData = await c.env.SESSION_KV.get(`session:${sessionId}`)
  
  if (!sessionData) {
    return c.json({ error: 'Session not found' }, 404)
  }
  
  return c.json({
    message: 'Session retrieved from Cloudflare KV',
    session: JSON.parse(sessionData)
  })
})

// User management endpoints (adapted from TR2B Express routes)
const users = new Map<string, any>()

app.get('/api/users', (c) => {
  return c.json({
    users: Array.from(users.values()),
    total: users.size,
    platform: 'Cloudflare Workers'
  })
})

app.post('/api/users', async (c) => {
  const { username, email } = await c.req.json()
  
  if (!username || !email) {
    return c.json({ error: 'Username and email are required' }, 400)
  }
  
  const id = crypto.randomUUID()
  const user = { 
    id, 
    username, 
    email, 
    createdAt: new Date().toISOString(),
    platform: 'Cloudflare Workers'
  }
  users.set(id, user)
  
  return c.json(user, 201)
})

// Serve static assets from TR2B build (handled by ASSETS binding)
app.use('/*', serveStatic({ root: './' }))

export default app
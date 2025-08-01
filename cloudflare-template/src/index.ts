import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { serveStatic } from 'hono/cloudflare-workers';
import { apiRoutes } from './api/routes';
import type { Env } from './types';

const app = new Hono<{ Bindings: Env }>();

// Middleware
app.use('*', logger());
app.use('*', cors({
  origin: '*',
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization'],
}));

// API routes (adapted from Express backend)
app.route('/api', apiRoutes);

// Health check endpoint
app.get('/health', (c: any) => {
  return c.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    environment: c.env.NODE_ENV || 'production'
  });
});

// Serve static assets for React frontend
app.get('/assets/*', serveStatic({ root: './' }));
app.get('/src/*', serveStatic({ root: './' }));

// Serve React app for all other routes (SPA routing)
app.get('*', serveStatic({ 
  path: './index.html',
  mimes: {
    html: 'text/html; charset=UTF-8',
  }
}));

// Error handling
app.onError((err: any, c: any) => {
  console.error('Application error:', err);
  return c.json({ 
    error: 'Internal Server Error',
    message: err.message,
    timestamp: new Date().toISOString()
  }, 500);
});

// 404 handler
app.notFound((c: any) => {
  // For API routes, return JSON error
  if (c.req.path.startsWith('/api/')) {
    return c.json({ error: 'Not Found', path: c.req.path }, 404);
  }
  
  // For frontend routes, serve the React app (SPA routing)
  return serveStatic({ path: './index.html' })(c);
});

export default app;

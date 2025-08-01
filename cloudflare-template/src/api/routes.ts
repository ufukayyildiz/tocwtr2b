import { Hono } from 'hono';
import type { Env } from '../types';

const api = new Hono<{ Bindings: Env }>();

// Storage interface adapted for Cloudflare Workers
interface IStorage {
  getUser(id: string): Promise<any | undefined>;
  getUserByUsername(username: string): Promise<any | undefined>;
  createUser(user: any): Promise<any>;
}

// In-memory storage (replace with KV or D1 for persistence)
class WorkersStorage implements IStorage {
  private users: Map<string, any> = new Map();

  async getUser(id: string): Promise<any | undefined> {
    return this.users.get(id);
  }

  async getUserByUsername(username: string): Promise<any | undefined> {
    return Array.from(this.users.values()).find(
      (user) => user.username === username,
    );
  }

  async createUser(insertUser: any): Promise<any> {
    const id = crypto.randomUUID();
    const user = { ...insertUser, id };
    this.users.set(id, user);
    return user;
  }
}

const storage = new WorkersStorage();

// User management routes
api.get('/users/:id', async (c: any) => {
  try {
    const id = c.req.param('id');
    const user = await storage.getUser(id);
    
    if (!user) {
      return c.json({ error: 'User not found' }, 404);
    }
    
    return c.json(user);
  } catch (error) {
    console.error('Error fetching user:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

api.post('/users', async (c: any) => {
  try {
    const userData = await c.req.json();
    
    // Basic validation
    if (!userData.username || !userData.password) {
      return c.json({ error: 'Username and password are required' }, 400);
    }
    
    // Check if user already exists
    const existingUser = await storage.getUserByUsername(userData.username);
    if (existingUser) {
      return c.json({ error: 'Username already exists' }, 409);
    }
    
    const user = await storage.createUser(userData);
    
    // Don't return password in response
    const { password, ...userResponse } = user;
    return c.json(userResponse, 201);
  } catch (error) {
    console.error('Error creating user:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// Authentication routes
api.post('/auth/login', async (c: any) => {
  try {
    const { username, password } = await c.req.json();
    
    if (!username || !password) {
      return c.json({ error: 'Username and password are required' }, 400);
    }
    
    const user = await storage.getUserByUsername(username);
    if (!user || user.password !== password) {
      return c.json({ error: 'Invalid credentials' }, 401);
    }
    
    // In a real app, you'd create a JWT token or session here
    const { password: _, ...userResponse } = user;
    return c.json({ 
      user: userResponse, 
      token: 'fake-jwt-token', // Replace with real JWT
      message: 'Login successful' 
    });
  } catch (error) {
    console.error('Error during login:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

api.post('/auth/logout', async (c: any) => {
  // In a real app, you'd invalidate the session/token here
  return c.json({ message: 'Logout successful' });
});

// Data endpoints (adapt these based on your TR2B app needs)
api.get('/data', async (c: any) => {
  try {
    // Replace with your actual data fetching logic
    const data = {
      items: [],
      total: 0,
      page: 1,
      limit: 10
    };
    
    return c.json(data);
  } catch (error) {
    console.error('Error fetching data:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

api.post('/data', async (c: any) => {
  try {
    const itemData = await c.req.json();
    
    // Add validation and processing logic here
    const newItem = {
      id: crypto.randomUUID(),
      ...itemData,
      createdAt: new Date().toISOString()
    };
    
    return c.json(newItem, 201);
  } catch (error) {
    console.error('Error creating data:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// Environment info (useful for debugging)
api.get('/env', async (c: any) => {
  return c.json({
    nodeEnv: c.env.NODE_ENV || 'production',
    timestamp: new Date().toISOString(),
    // Add other non-sensitive environment info here
  });
});

export { api as apiRoutes };

// Cloudflare Workers environment bindings
export interface Env {
  // Environment variables
  NODE_ENV?: string;
  DATABASE_URL?: string;
  API_KEY?: string;
  
  // KV namespaces
  SESSION_KV?: KVNamespace;
  
  // R2 buckets (if needed)
  ASSETS_BUCKET?: R2Bucket;
  
  // Durable Objects (if needed)
  TR2B_DO?: DurableObjectNamespace;
  
  // Analytics Engine (if needed)
  ANALYTICS?: AnalyticsEngineDataset;
}

// User types (adapt from your shared schema)
export interface User {
  id: string;
  username: string;
  password: string;
}

export interface InsertUser {
  username: string;
  password: string;
}

// API response types
export interface ApiResponse<T = any> {
  data?: T;
  error?: string;
  message?: string;
  timestamp?: string;
}

// Session types
export interface Session {
  userId: string;
  username: string;
  createdAt: string;
  expiresAt: string;
}

// Request context extensions
export interface AppContext {
  user?: User;
  session?: Session;
}

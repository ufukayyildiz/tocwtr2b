import type { Express } from "express";
import { createServer, type Server } from "http";
import { storage } from "./storage";

export async function registerRoutes(app: Express): Promise<Server> {
  // Health check endpoint
  app.get("/api/health", (req, res) => {
    res.json({ 
      status: "ok", 
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || "development",
      message: "TR2B server is running"
    });
  });

  // Environment info endpoint
  app.get("/api/env", (req, res) => {
    res.json({
      nodeEnv: process.env.NODE_ENV || "development",
      timestamp: new Date().toISOString(),
      port: process.env.PORT || "5000",
      platform: "TR2B Application"
    });
  });

  // Demo data endpoint
  app.get("/api/data", (req, res) => {
    res.json({
      message: "TR2B API is working",
      data: [
        { id: 1, name: "Demo Item 1", type: "sample" },
        { id: 2, name: "Demo Item 2", type: "sample" },
        { id: 3, name: "Demo Item 3", type: "sample" }
      ],
      total: 3,
      timestamp: new Date().toISOString()
    });
  });

  // User demo endpoints (using in-memory storage for now)
  const users = new Map();
  
  app.get("/api/users", (req, res) => {
    res.json({
      users: Array.from(users.values()),
      total: users.size
    });
  });

  app.post("/api/users", (req, res) => {
    const { username, email } = req.body;
    
    if (!username || !email) {
      return res.status(400).json({ error: "Username and email are required" });
    }
    
    const id = crypto.randomUUID();
    const user = { id, username, email, createdAt: new Date().toISOString() };
    users.set(id, user);
    
    res.status(201).json(user);
  });

  const httpServer = createServer(app);

  return httpServer;
}

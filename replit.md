# TR2B (Template React To Backend)

## Overview

TR2B is a full-stack web application built with a modern tech stack featuring React on the frontend and Express.js on the backend. The project uses TypeScript throughout, implements a component-based UI system with Radix UI primitives and Tailwind CSS for styling. It includes database integration through Drizzle ORM with PostgreSQL support and provides a complete development environment with Vite for the frontend build process. The application also includes deployment templates for Cloudflare Workers, making it suitable for edge deployment scenarios.

## User Preferences

Preferred communication style: Simple, everyday language.

## Recent Changes

- **Template Structure Update (2025-01-31)**: Recreated the TR2B Cloudflare Workers template to follow the exact format of official Cloudflare templates like R2-Explorer
- **Proper Template Format**: Implemented wrangler.json configuration, package.json with cloudflare metadata, and official template structure
- **GitHub Repository Integration**: Added automated setup script that handles private repository cloning and building
- **One-Click Deployment**: Created template that matches Cloudflare's official template requirements for deployment marketplace

## System Architecture

### Frontend Architecture
- **Framework**: React 18 with TypeScript for type safety and modern development
- **Build Tool**: Vite for fast development server and optimized builds
- **Routing**: Wouter for lightweight client-side routing
- **State Management**: TanStack Query for server state management and caching
- **UI Components**: Radix UI primitives for accessible, unstyled components
- **Styling**: Tailwind CSS with custom CSS variables for theming and responsive design
- **Component Library**: Shadcn/ui components following the "new-york" style variant

### Backend Architecture
- **Framework**: Express.js with TypeScript for the REST API server
- **Database Layer**: Drizzle ORM for type-safe database operations
- **Database**: PostgreSQL (configured for Neon Database service)
- **Storage Interface**: Abstracted storage layer with in-memory implementation for development
- **Development Server**: Hot reload support with custom logging middleware

### Data Storage Solutions
- **Primary Database**: PostgreSQL with Drizzle ORM for schema management
- **Migration System**: Drizzle Kit for database schema migrations
- **Session Storage**: PostgreSQL-based session storage with connect-pg-simple
- **Schema Definition**: Centralized schema in `/shared/schema.ts` using Drizzle with Zod validation

### Authentication and Authorization
- **Session Management**: Express sessions with PostgreSQL session store
- **User Schema**: Basic user model with id, username, and password fields
- **Validation**: Zod schemas for runtime type validation of user inputs

### Project Structure
- **Monorepo Setup**: Client and server code in separate directories with shared types
- **Path Aliases**: TypeScript path mapping for clean imports (@/, @shared/, @assets/)
- **Development Environment**: Integrated development server with Vite middleware
- **Production Build**: Separate build processes for client (Vite) and server (esbuild)

## External Dependencies

### Database Services
- **Neon Database**: PostgreSQL hosting service for production database
- **Drizzle ORM**: Type-safe database toolkit with PostgreSQL dialect support

### UI and Styling
- **Radix UI**: Comprehensive collection of low-level UI primitives
- **Tailwind CSS**: Utility-first CSS framework with custom configuration
- **Lucide React**: Icon library for consistent iconography
- **Embla Carousel**: Carousel component for interactive content

### Development Tools
- **Vite**: Frontend build tool with React plugin and development server
- **TypeScript**: Type checking and compilation for both frontend and backend
- **PostCSS**: CSS processing with Tailwind CSS and Autoprefixer plugins

### Cloud Deployment
- **Cloudflare Workers**: Edge computing platform with deployment template
- **Hono**: Lightweight web framework for Cloudflare Workers adaptation
- **Wrangler**: Cloudflare Workers CLI for deployment and management

### Form and Validation
- **React Hook Form**: Form state management with TypeScript support
- **Hookform Resolvers**: Integration layer for schema validation
- **Zod**: Runtime schema validation and TypeScript inference

### Additional Services
- **TanStack Query**: Server state management, caching, and synchronization
- **Date-fns**: Date manipulation and formatting utilities
- **Class Variance Authority**: Utility for creating variant-based component APIs
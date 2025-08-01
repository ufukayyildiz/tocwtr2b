import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ExternalLink, Github, Zap, Cloud, Code, Rocket } from "lucide-react";

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 dark:from-gray-900 dark:to-gray-800">
      <div className="container mx-auto px-4 py-16">
        <div className="max-w-4xl mx-auto text-center">
          {/* Hero Section */}
          <div className="mb-16">
            <div className="flex items-center justify-center mb-6">
              <div className="bg-blue-600 text-white p-4 rounded-full">
                <Rocket className="h-8 w-8" />
              </div>
            </div>
            <h1 className="text-4xl md:text-6xl font-bold text-gray-900 dark:text-white mb-6">
              TR2B
              <span className="bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                {" "}Template
              </span>
            </h1>
            <p className="text-xl text-gray-600 dark:text-gray-300 mb-8 max-w-2xl mx-auto">
              Template React To Backend - A full-stack web application built with modern tech stack, 
              ready for Cloudflare Workers deployment.
            </p>
            <div className="flex flex-wrap gap-3 justify-center mb-8">
              <Badge variant="secondary" className="px-3 py-1">
                <Code className="h-4 w-4 mr-1" />
                React + TypeScript
              </Badge>
              <Badge variant="secondary" className="px-3 py-1">
                <Zap className="h-4 w-4 mr-1" />
                Express.js
              </Badge>
              <Badge variant="secondary" className="px-3 py-1">
                <Cloud className="h-4 w-4 mr-1" />
                Cloudflare Workers
              </Badge>
            </div>
          </div>

          {/* Features Grid */}
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 mb-16">
            <Card className="p-6 hover:shadow-lg transition-shadow">
              <CardHeader className="pb-4">
                <CardTitle className="flex items-center text-lg">
                  <Rocket className="h-5 w-5 mr-2 text-blue-600" />
                  Modern Stack
                </CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription>
                  Built with React 18, TypeScript, Vite, and Express.js for maximum developer experience.
                </CardDescription>
              </CardContent>
            </Card>

            <Card className="p-6 hover:shadow-lg transition-shadow">
              <CardHeader className="pb-4">
                <CardTitle className="flex items-center text-lg">
                  <Cloud className="h-5 w-5 mr-2 text-blue-600" />
                  Edge Deploy
                </CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription>
                  Optimized for Cloudflare Workers with automatic asset optimization and edge computing.
                </CardDescription>
              </CardContent>
            </Card>

            <Card className="p-6 hover:shadow-lg transition-shadow">
              <CardHeader className="pb-4">
                <CardTitle className="flex items-center text-lg">
                  <Code className="h-5 w-5 mr-2 text-blue-600" />
                  Full-Stack
                </CardTitle>
              </CardHeader>
              <CardContent>
                <CardDescription>
                  Complete frontend and backend solution with database integration and API routes.
                </CardDescription>
              </CardContent>
            </Card>
          </div>

          {/* Deployment Status */}
          <Card className="bg-green-50 dark:bg-green-900/20 border-green-200 dark:border-green-800 mb-12">
            <CardHeader>
              <CardTitle className="text-green-800 dark:text-green-200 flex items-center justify-center">
                <Zap className="h-5 w-5 mr-2" />
                Deployment Ready
              </CardTitle>
            </CardHeader>
            <CardContent>
              <CardDescription className="text-green-700 dark:text-green-300">
                This TR2B application is configured and ready for one-click deployment to Cloudflare Workers.
                The deployment template automatically handles private repository access, builds the frontend,
                and deploys to the edge.
              </CardDescription>
            </CardContent>
          </Card>

          {/* Action Buttons */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center mb-12">
            <Button asChild size="lg" className="bg-blue-600 hover:bg-blue-700">
              <a 
                href="https://github.com/ufukayyildiz/TR2B_REPLIT_OR_DATA.git" 
                target="_blank" 
                rel="noopener noreferrer"
                className="flex items-center"
              >
                <Github className="h-5 w-5 mr-2" />
                View Source
                <ExternalLink className="h-4 w-4 ml-2" />
              </a>
            </Button>
            <Button asChild variant="outline" size="lg">
              <a 
                href="/api/env" 
                target="_blank" 
                rel="noopener noreferrer"
                className="flex items-center"
              >
                <Zap className="h-5 w-5 mr-2" />
                Test API
                <ExternalLink className="h-4 w-4 ml-2" />
              </a>
            </Button>
          </div>

          {/* Tech Stack */}
          <div className="text-center">
            <h3 className="text-2xl font-semibold text-gray-900 dark:text-white mb-6">
              Powered By
            </h3>
            <div className="flex flex-wrap gap-6 justify-center items-center text-gray-600 dark:text-gray-400">
              <div className="flex items-center space-x-2">
                <span className="font-medium">React</span>
              </div>
              <div className="flex items-center space-x-2">
                <span className="font-medium">TypeScript</span>
              </div>
              <div className="flex items-center space-x-2">
                <span className="font-medium">Vite</span>
              </div>
              <div className="flex items-center space-x-2">
                <span className="font-medium">Express.js</span>
              </div>
              <div className="flex items-center space-x-2">
                <span className="font-medium">Tailwind CSS</span>
              </div>
              <div className="flex items-center space-x-2">
                <span className="font-medium">Drizzle ORM</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
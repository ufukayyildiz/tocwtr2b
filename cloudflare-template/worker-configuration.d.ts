interface CloudflareBindings {
  ASSETS: Fetcher
  SESSION_KV: KVNamespace
}

declare global {
  interface CloudflareWorkerGlobalScope {
    ASSETS: Fetcher
    SESSION_KV: KVNamespace
  }
}

export {};
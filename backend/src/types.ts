import type { D1Database } from '@cloudflare/workers-types';

export interface Env {
  // D1 Database binding
  DB: D1Database;

  // Environment variables
  ENVIRONMENT?: string;

  // Optional: KV namespace for caching
  CACHE?: KVNamespace;

  // Optional: Durable Object for rate limiting
  RATE_LIMITER?: DurableObjectNamespace;
}

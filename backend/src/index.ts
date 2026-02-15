import { Database } from './database';
import { EventBatchPayloadSchema, RegisterAppSchema } from './schemas';
import type { Env } from './types';

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);
    const path = url.pathname;
    const method = request.method;

    // CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, X-API-Key',
      'Access-Control-Max-Age': '86400',
    };

    // Handle CORS preflight
    if (method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    const db = new Database(env.DB);

    try {
      // Routes
      if (path === '/v1/events' && method === 'POST') {
        return await handleEventIngestion(request, db, corsHeaders);
      }

      if (path.startsWith('/v1/apps/') && path.endsWith('/summary') && method === 'GET') {
        const appId = path.split('/')[3];
        return await handleAppSummary(request, db, appId, corsHeaders);
      }

      if (path.startsWith('/v1/apps/') && path.endsWith('/insights') && method === 'GET') {
        const appId = path.split('/')[3];
        return await handleInsights(request, db, appId, corsHeaders);
      }

      if (path.startsWith('/v1/apps/') && path.endsWith('/events') && method === 'GET') {
        const appId = path.split('/')[3];
        return await handleGetEvents(request, db, appId, corsHeaders);
      }

      if (path === '/v1/auth/register' && method === 'POST') {
        return await handleRegisterApp(request, db, corsHeaders);
      }

      if (path === '/v1/health' && method === 'GET') {
        return jsonResponse({ status: 'ok', timestamp: Date.now() }, 200, corsHeaders);
      }

      // 404 Not Found
      return jsonResponse({ error: 'Not found' }, 404, corsHeaders);
    } catch (error) {
      console.error('Error handling request:', error);
      return jsonResponse(
        { error: 'Internal server error', message: error instanceof Error ? error.message : String(error) },
        500,
        corsHeaders
      );
    }
  },
};

// Route handlers

async function handleEventIngestion(
  request: Request,
  db: Database,
  corsHeaders: Record<string, string>
): Promise<Response> {
  // Rate limiting (simplified - in production use Durable Objects)
  const rateLimitKey = request.headers.get('cf-connecting-ip') || 'unknown';
  // TODO: Implement proper rate limiting

  // Authenticate
  const apiKey = request.headers.get('x-api-key');
  if (!apiKey) {
    return jsonResponse({ error: 'Missing API key' }, 401, corsHeaders);
  }

  const app = await db.getAppByApiKey(apiKey);
  if (!app) {
    return jsonResponse({ error: 'Invalid API key' }, 401, corsHeaders);
  }

  // Parse and validate payload
  let payload;
  try {
    const body = await request.json();
    payload = EventBatchPayloadSchema.parse(body);
  } catch (error) {
    return jsonResponse(
      { error: 'Invalid payload', details: error instanceof Error ? error.message : String(error) },
      400,
      corsHeaders
    );
  }

  // Insert events
  await db.insertEvents(app.id, payload.events);

  // Update user tracking for events with user_id
  for (const event of payload.events) {
    if (event.context.user.user_id) {
      await db.upsertUser(
        app.id,
        event.context.user.user_id,
        event.context.user.session_count,
        event.context.user.custom_properties || {}
      );
    }
  }

  // Log API usage
  await db.logApiUsage(app.id, '/v1/events', 'POST', 200);

  return jsonResponse(
    {
      success: true,
      events_received: payload.events.length,
      app_id: app.id,
    },
    200,
    corsHeaders
  );
}

async function handleAppSummary(
  request: Request,
  db: Database,
  appId: string,
  corsHeaders: Record<string, string>
): Promise<Response> {
  // Authenticate
  const apiKey = request.headers.get('x-api-key');
  if (!apiKey) {
    return jsonResponse({ error: 'Missing API key' }, 401, corsHeaders);
  }

  const app = await db.getAppByApiKey(apiKey);
  if (!app || app.id !== appId) {
    return jsonResponse({ error: 'Unauthorized' }, 403, corsHeaders);
  }

  // Get event count
  const eventCount = await db.getEventCount(appId);

  // Get breakdowns
  const url = new URL(request.url);
  const eventName = url.searchParams.get('event') || 'paywall_viewed';
  const dimension = (url.searchParams.get('dimension') || 'country') as any;

  const breakdown = await db.getEventsByContext(appId, eventName, dimension);

  return jsonResponse(
    {
      app_id: appId,
      total_events: eventCount,
      breakdown,
    },
    200,
    corsHeaders
  );
}

async function handleInsights(
  request: Request,
  db: Database,
  appId: string,
  corsHeaders: Record<string, string>
): Promise<Response> {
  // Authenticate
  const apiKey = request.headers.get('x-api-key');
  if (!apiKey) {
    return jsonResponse({ error: 'Missing API key' }, 401, corsHeaders);
  }

  const app = await db.getAppByApiKey(apiKey);
  if (!app || app.id !== appId) {
    return jsonResponse({ error: 'Unauthorized' }, 403, corsHeaders);
  }

  // Get insights (Phase 2 - returns empty for now)
  const insights = await db.getInsights(appId);

  return jsonResponse(
    {
      insights: insights.map((i) => ({
        type: i.type,
        severity: i.severity,
        message: i.message,
        recommendation: i.recommendation,
        affected_context: i.affected_context ? JSON.parse(i.affected_context) : {},
      })),
      note: 'Phase 2 feature - AI insights coming soon',
    },
    200,
    corsHeaders
  );
}

async function handleGetEvents(
  request: Request,
  db: Database,
  appId: string,
  corsHeaders: Record<string, string>
): Promise<Response> {
  // Authenticate
  const apiKey = request.headers.get('x-api-key');
  if (!apiKey) {
    return jsonResponse({ error: 'Missing API key' }, 401, corsHeaders);
  }

  const app = await db.getAppByApiKey(apiKey);
  if (!app || app.id !== appId) {
    return jsonResponse({ error: 'Unauthorized' }, 403, corsHeaders);
  }

  const url = new URL(request.url);
  const limit = Math.min(parseInt(url.searchParams.get('limit') || '100'), 1000);

  const events = await db.getRecentEvents(appId, limit);

  return jsonResponse(
    {
      events: events.map((e) => ({
        id: e.id,
        event_name: e.event_name,
        properties: JSON.parse(e.properties),
        context: JSON.parse(e.context),
        timestamp: e.timestamp,
      })),
    },
    200,
    corsHeaders
  );
}

async function handleRegisterApp(
  request: Request,
  db: Database,
  corsHeaders: Record<string, string>
): Promise<Response> {
  // Parse and validate
  let data;
  try {
    const body = await request.json();
    data = RegisterAppSchema.parse(body);
  } catch (error) {
    return jsonResponse(
      { error: 'Invalid payload', details: error instanceof Error ? error.message : String(error) },
      400,
      corsHeaders
    );
  }

  // Create app
  const app = await db.createApp(data.name, data.environment);

  return jsonResponse(
    {
      id: app.id,
      name: app.name,
      api_key: app.api_key,
      environment: app.environment,
      created_at: app.created_at,
    },
    201,
    corsHeaders
  );
}

// Helper functions

function jsonResponse(
  data: any,
  status: number = 200,
  headers: Record<string, string> = {}
): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...headers,
    },
  });
}

import type { D1Database } from '@cloudflare/workers-types';
import type { ContextEvent, ContextSnapshot } from './schemas';

export class Database {
  constructor(private db: D1Database) {}

  // App management
  async getAppByApiKey(apiKey: string): Promise<App | null> {
    const result = await this.db
      .prepare('SELECT * FROM apps WHERE api_key = ?')
      .bind(apiKey)
      .first<App>();

    return result;
  }

  async createApp(name: string, environment: 'production' | 'test' = 'production'): Promise<App> {
    const id = crypto.randomUUID();
    const apiKey = generateApiKey(environment);
    const now = Math.floor(Date.now() / 1000);

    await this.db
      .prepare(
        'INSERT INTO apps (id, name, api_key, environment, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)'
      )
      .bind(id, name, apiKey, environment, now, now)
      .run();

    return {
      id,
      name,
      api_key: apiKey,
      environment,
      created_at: now,
      updated_at: now,
      settings: null,
    };
  }

  // Event ingestion
  async insertEvents(appId: string, events: ContextEvent[]): Promise<void> {
    const now = Math.floor(Date.now() / 1000);

    // Batch insert using D1's batch API
    const statements = events.map((event) =>
      this.db
        .prepare(
          'INSERT INTO events (id, app_id, event_name, properties, context, timestamp, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)'
        )
        .bind(
          event.id,
          appId,
          event.name,
          JSON.stringify(event.properties || {}),
          JSON.stringify(event.context),
          new Date(event.timestamp).getTime() / 1000,
          now
        )
    );

    await this.db.batch(statements);
  }

  // Analytics queries
  async getEventsByContext(
    appId: string,
    eventName: string,
    dimension: ContextDimension,
    startDate?: number,
    endDate?: number
  ): Promise<ContextBreakdown[]> {
    const start = startDate || Math.floor(Date.now() / 1000) - 30 * 24 * 60 * 60; // 30 days ago
    const end = endDate || Math.floor(Date.now() / 1000);

    let jsonPath: string;
    switch (dimension) {
      case 'country':
        jsonPath = '$.geo.country_code';
        break;
      case 'dayPeriod':
        jsonPath = '$.time.day_period';
        break;
      case 'device':
        jsonPath = '$.device.model';
        break;
      case 'region':
        jsonPath = '$.geo.region';
        break;
      default:
        jsonPath = '$.geo.country_code';
    }

    const query = `
      SELECT
        json_extract(context, ?) as dimension_value,
        COUNT(*) as event_count,
        COUNT(DISTINCT json_extract(context, '$.user.user_id')) as unique_users
      FROM events
      WHERE app_id = ?
        AND event_name = ?
        AND timestamp >= ?
        AND timestamp <= ?
      GROUP BY dimension_value
      ORDER BY event_count DESC
      LIMIT 50
    `;

    const results = await this.db
      .prepare(query)
      .bind(jsonPath, appId, eventName, start, end)
      .all<ContextBreakdown>();

    return results.results || [];
  }

  async getConversionFunnel(appId: string, steps: string[]): Promise<FunnelStep[]> {
    const results: FunnelStep[] = [];

    for (let i = 0; i < steps.length; i++) {
      const step = steps[i];
      const count = await this.db
        .prepare('SELECT COUNT(DISTINCT json_extract(context, "$.user.user_id")) as count FROM events WHERE app_id = ? AND event_name = ?')
        .bind(appId, step)
        .first<{ count: number }>();

      results.push({
        step: step,
        index: i,
        count: count?.count || 0,
        dropoff: i > 0 && results[i - 1].count > 0
          ? ((results[i - 1].count - (count?.count || 0)) / results[i - 1].count) * 100
          : 0,
      });
    }

    return results;
  }

  async getRecentEvents(appId: string, limit: number = 100): Promise<EventRow[]> {
    const results = await this.db
      .prepare('SELECT * FROM events WHERE app_id = ? ORDER BY timestamp DESC LIMIT ?')
      .bind(appId, limit)
      .all<EventRow>();

    return results.results || [];
  }

  async getEventCount(appId: string, startDate?: number, endDate?: number): Promise<number> {
    const start = startDate || 0;
    const end = endDate || Math.floor(Date.now() / 1000);

    const result = await this.db
      .prepare('SELECT COUNT(*) as count FROM events WHERE app_id = ? AND timestamp >= ? AND timestamp <= ?')
      .bind(appId, start, end)
      .first<{ count: number }>();

    return result?.count || 0;
  }

  // User tracking
  async upsertUser(
    appId: string,
    userId: string,
    sessionCount: number,
    properties: Record<string, any>
  ): Promise<void> {
    const now = Math.floor(Date.now() / 1000);

    await this.db
      .prepare(
        `INSERT INTO users (id, app_id, user_id, first_seen, last_seen, session_count, total_events, properties)
         VALUES (?, ?, ?, ?, ?, ?, 1, ?)
         ON CONFLICT(app_id, user_id) DO UPDATE SET
           last_seen = ?,
           session_count = ?,
           total_events = total_events + 1,
           properties = ?`
      )
      .bind(
        crypto.randomUUID(),
        appId,
        userId,
        now,
        now,
        sessionCount,
        JSON.stringify(properties),
        now,
        sessionCount,
        JSON.stringify(properties)
      )
      .run();
  }

  // Insights (Phase 2 stub)
  async getInsights(appId: string, limit: number = 10): Promise<InsightRow[]> {
    const results = await this.db
      .prepare('SELECT * FROM insights WHERE app_id = ? ORDER BY created_at DESC LIMIT ?')
      .bind(appId, limit)
      .all<InsightRow>();

    return results.results || [];
  }

  // API usage tracking
  async logApiUsage(appId: string, endpoint: string, method: string, statusCode: number): Promise<void> {
    const now = Math.floor(Date.now() / 1000);

    await this.db
      .prepare(
        'INSERT INTO api_usage (id, app_id, endpoint, method, status_code, timestamp) VALUES (?, ?, ?, ?, ?, ?)'
      )
      .bind(crypto.randomUUID(), appId, endpoint, method, statusCode, now)
      .run();
  }
}

// Helper functions
function generateApiKey(environment: 'production' | 'test'): string {
  const prefix = environment === 'production' ? 'ck_live' : 'ck_test';
  const random = Array.from(crypto.getRandomValues(new Uint8Array(16)))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
  return `${prefix}_${random}`;
}

// Type definitions
export interface App {
  id: string;
  name: string;
  api_key: string;
  environment: string;
  created_at: number;
  updated_at: number;
  settings: string | null;
}

export interface EventRow {
  id: string;
  app_id: string;
  event_name: string;
  properties: string; // JSON
  context: string; // JSON
  timestamp: number;
  created_at: number;
}

export interface ContextBreakdown {
  dimension_value: string;
  event_count: number;
  unique_users: number;
}

export interface FunnelStep {
  step: string;
  index: number;
  count: number;
  dropoff: number;
}

export interface InsightRow {
  id: string;
  app_id: string;
  type: string;
  severity: string;
  message: string;
  affected_context: string; // JSON
  recommendation: string | null;
  confidence: number | null;
  created_at: number;
  expires_at: number | null;
}

export type ContextDimension = 'country' | 'dayPeriod' | 'device' | 'region';

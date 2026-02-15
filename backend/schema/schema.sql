-- ContextKit Database Schema for Cloudflare D1

-- Apps table - stores registered apps and API keys
CREATE TABLE IF NOT EXISTS apps (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    api_key TEXT UNIQUE NOT NULL,
    environment TEXT DEFAULT 'production', -- 'production' or 'test'
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    settings TEXT -- JSON blob for app settings
);

CREATE INDEX idx_apps_api_key ON apps(api_key);
CREATE INDEX idx_apps_created_at ON apps(created_at);

-- Events table - stores all tracked events with context
CREATE TABLE IF NOT EXISTS events (
    id TEXT PRIMARY KEY,
    app_id TEXT NOT NULL,
    event_name TEXT NOT NULL,
    properties TEXT, -- JSON blob
    context TEXT NOT NULL, -- JSON blob with full ContextSnapshot
    timestamp INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (app_id) REFERENCES apps(id)
);

CREATE INDEX idx_events_app_id ON events(app_id);
CREATE INDEX idx_events_event_name ON events(event_name);
CREATE INDEX idx_events_timestamp ON events(timestamp);
CREATE INDEX idx_events_app_event_time ON events(app_id, event_name, timestamp);

-- Context aggregations table - pre-computed analytics
CREATE TABLE IF NOT EXISTS context_aggregations (
    id TEXT PRIMARY KEY,
    app_id TEXT NOT NULL,
    event_name TEXT NOT NULL,
    dimension TEXT NOT NULL, -- 'country', 'dayPeriod', 'device', etc.
    dimension_value TEXT NOT NULL,
    event_count INTEGER DEFAULT 0,
    unique_users INTEGER DEFAULT 0,
    period_start INTEGER NOT NULL, -- Unix timestamp
    period_end INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (app_id) REFERENCES apps(id)
);

CREATE INDEX idx_agg_app_event ON context_aggregations(app_id, event_name);
CREATE INDEX idx_agg_dimension ON context_aggregations(dimension, dimension_value);
CREATE INDEX idx_agg_period ON context_aggregations(period_start, period_end);

-- Insights table - AI-generated insights (Phase 2)
CREATE TABLE IF NOT EXISTS insights (
    id TEXT PRIMARY KEY,
    app_id TEXT NOT NULL,
    type TEXT NOT NULL, -- 'anomaly', 'trend', 'benchmark', 'opportunity'
    severity TEXT NOT NULL, -- 'low', 'medium', 'high', 'critical'
    message TEXT NOT NULL,
    affected_context TEXT, -- JSON blob
    recommendation TEXT,
    confidence REAL,
    created_at INTEGER NOT NULL,
    expires_at INTEGER,
    FOREIGN KEY (app_id) REFERENCES apps(id)
);

CREATE INDEX idx_insights_app_id ON insights(app_id);
CREATE INDEX idx_insights_type ON insights(type);
CREATE INDEX idx_insights_severity ON insights(severity);

-- Users table - track unique users across apps
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    app_id TEXT NOT NULL,
    user_id TEXT NOT NULL, -- Developer-provided user ID
    first_seen INTEGER NOT NULL,
    last_seen INTEGER NOT NULL,
    session_count INTEGER DEFAULT 0,
    total_events INTEGER DEFAULT 0,
    properties TEXT, -- JSON blob
    FOREIGN KEY (app_id) REFERENCES apps(id),
    UNIQUE(app_id, user_id)
);

CREATE INDEX idx_users_app_id ON users(app_id);
CREATE INDEX idx_users_user_id ON users(user_id);
CREATE INDEX idx_users_last_seen ON users(last_seen);

-- API usage tracking
CREATE TABLE IF NOT EXISTS api_usage (
    id TEXT PRIMARY KEY,
    app_id TEXT NOT NULL,
    endpoint TEXT NOT NULL,
    method TEXT NOT NULL,
    status_code INTEGER,
    timestamp INTEGER NOT NULL,
    FOREIGN KEY (app_id) REFERENCES apps(id)
);

CREATE INDEX idx_usage_app_id ON api_usage(app_id);
CREATE INDEX idx_usage_timestamp ON api_usage(timestamp);

-- Seed data: Create a test app
INSERT OR IGNORE INTO apps (id, name, api_key, environment, created_at, updated_at)
VALUES (
    'test-app-001',
    'Test App',
    'ck_test_development_12345',
    'test',
    strftime('%s', 'now'),
    strftime('%s', 'now')
);

INSERT OR IGNORE INTO apps (id, name, api_key, environment, created_at, updated_at)
VALUES (
    'demo-app-001',
    'Demo App',
    'ck_live_demo_67890',
    'production',
    strftime('%s', 'now'),
    strftime('%s', 'now')
);

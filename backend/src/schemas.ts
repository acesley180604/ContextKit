import { z } from 'zod';

// Context schemas matching Swift models

export const DayPeriodSchema = z.enum(['morning', 'afternoon', 'evening', 'night']);

export const TimeContextSchema = z.object({
  hour: z.number().int().min(0).max(23),
  day_of_week: z.number().int().min(1).max(7),
  is_weekend: z.boolean(),
  timezone: z.string(),
  local_time: z.string(),
  day_period: DayPeriodSchema,
});

export const GeoContextSchema = z.object({
  country_code: z.string(),
  region: z.string(),
  locale_identifier: z.string(),
  currency_code: z.string(),
  language_code: z.string(),
});

export const BatteryStateSchema = z.enum(['unknown', 'unplugged', 'charging', 'full']);
export const NetworkTypeSchema = z.enum(['unknown', 'wifi', 'cellular', 'offline']);

export const DeviceContextSchema = z.object({
  model: z.string(),
  os_version: z.string(),
  screen_width: z.number(),
  screen_height: z.number(),
  screen_scale: z.number(),
  battery_level: z.number(),
  battery_state: BatteryStateSchema,
  network_type: NetworkTypeSchema,
  is_low_power_mode: z.boolean(),
  available_disk_space: z.number(),
  total_memory: z.number(),
});

export const UserContextSchema = z.object({
  user_id: z.string().optional().nullable(),
  segment: z.string().optional().nullable(),
  session_count: z.number().int(),
  days_since_install: z.number().int(),
  custom_properties: z.record(z.string()).optional(),
});

export const SessionContextSchema = z.object({
  session_id: z.string(),
  duration: z.number(),
  screen_view_count: z.number().int(),
  event_count: z.number().int(),
  entry_screen: z.string().optional().nullable(),
});

export const ContextSnapshotSchema = z.object({
  time: TimeContextSchema,
  geo: GeoContextSchema,
  device: DeviceContextSchema,
  user: UserContextSchema,
  session: SessionContextSchema,
  sdk_version: z.string(),
  captured_at: z.string(), // ISO8601 date
});

export const ContextEventSchema = z.object({
  id: z.string(),
  name: z.string(),
  properties: z.record(z.any()).optional(),
  context: ContextSnapshotSchema,
  timestamp: z.string(), // ISO8601 date
});

export const EventBatchPayloadSchema = z.object({
  api_key: z.string().regex(/^ck_(live|test)_/),
  events: z.array(ContextEventSchema).min(1).max(100),
  sdk_version: z.string(),
  uploaded_at: z.string(), // ISO8601 date
});

// API request/response schemas

export const RegisterAppSchema = z.object({
  name: z.string().min(1).max(255),
  environment: z.enum(['production', 'test']).default('production'),
});

export const AppResponseSchema = z.object({
  id: z.string(),
  name: z.string(),
  api_key: z.string(),
  environment: z.string(),
  created_at: z.number(),
});

export const InsightSchema = z.object({
  type: z.enum(['anomaly', 'trend', 'benchmark', 'opportunity']),
  message: z.string(),
  severity: z.enum(['low', 'medium', 'high', 'critical']),
  affected_context: z.record(z.string()).optional(),
  recommendation: z.string().optional(),
});

export const RecommendationSchema = z.object({
  action: z.string(),
  confidence: z.number().min(0).max(1),
  benchmark: z.string().optional(),
  expected_impact: z.string().optional(),
});

// Type exports
export type DayPeriod = z.infer<typeof DayPeriodSchema>;
export type TimeContext = z.infer<typeof TimeContextSchema>;
export type GeoContext = z.infer<typeof GeoContextSchema>;
export type DeviceContext = z.infer<typeof DeviceContextSchema>;
export type UserContext = z.infer<typeof UserContextSchema>;
export type SessionContext = z.infer<typeof SessionContextSchema>;
export type ContextSnapshot = z.infer<typeof ContextSnapshotSchema>;
export type ContextEvent = z.infer<typeof ContextEventSchema>;
export type EventBatchPayload = z.infer<typeof EventBatchPayloadSchema>;
export type RegisterApp = z.infer<typeof RegisterAppSchema>;
export type AppResponse = z.infer<typeof AppResponseSchema>;
export type Insight = z.infer<typeof InsightSchema>;
export type Recommendation = z.infer<typeof RecommendationSchema>;

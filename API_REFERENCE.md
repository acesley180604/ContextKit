# ContextKit API Reference

Complete API documentation with examples and JSON payloads.

---

## Table of Contents

- [Configuration](#configuration)
- [Event Tracking](#event-tracking)
- [User Management](#user-management)
- [Screen Tracking](#screen-tracking)
- [Utilities](#utilities)
- [JSON Payload Examples](#json-payload-examples)

---

## Configuration

### `ContextKit.configure()`

Initialize the SDK. Call once at app launch.

**Signature:**
```swift
static func configure(
    apiKey: String,
    config: ContextKitConfig? = nil
)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `apiKey` | `String` | ✅ | Your API key (`ck_live_xxx` or `ck_test_xxx`) |
| `config` | `ContextKitConfig?` | ❌ | Optional configuration (defaults to `.default`) |

**Examples:**

**Minimal (recommended):**
```swift
import ContextKit

@main
struct MyApp: App {
    init() {
        ContextKit.configure(apiKey: "ck_live_abc123")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

**With custom config:**
```swift
let config = ContextKitConfig(
    apiKey: "ck_live_abc123",
    uploadInterval: 15.0,       // Upload every 15 seconds (default: 30)
    maxBatchSize: 10,            // Batch size of 10 events (default: 20)
    debugMode: true,             // Enable debug overlay
    enableGeo: true,             // Capture geo context (default: true)
    enableDevice: true,          // Capture device context (default: true)
    enableTime: true             // Capture time context (default: true)
)

ContextKit.configure(apiKey: "ck_live_abc123", config: config)
```

**Notes:**
- Call before any `track()` calls
- Events tracked before `configure()` are dropped
- SDK is a singleton - calling `configure()` twice overwrites previous config

---

## Event Tracking

### `ContextKit.track()`

Track a named event with automatic context capture.

**Signature:**
```swift
static func track(
    _ eventName: String,
    properties: [String: Any] = [:]
)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `eventName` | `String` | ✅ | Event name (use `snake_case`) |
| `properties` | `[String: Any]` | ❌ | Custom properties (supports: `String`, `Int`, `Double`, `Bool`) |

**Examples:**

**Simple event:**
```swift
ContextKit.track("app_opened")
```

**With properties:**
```swift
ContextKit.track("paywall_viewed", properties: [
    "plan": "annual",
    "price": 49.99,
    "currency": "USD"
])
```

**Purchase event:**
```swift
ContextKit.track("purchase_completed", properties: [
    "plan": "annual",
    "price": 49.99,
    "revenue": 49.99,
    "currency": "USD",
    "payment_method": "apple_pay"
])
```

**Funnel step:**
```swift
ContextKit.track("onboarding_step_3", properties: [
    "step_name": "permissions",
    "skipped": false
])
```

**What gets auto-captured:**

Every `track()` call automatically captures:
- ⏰ Time context (hour, day, period, timezone)
- 🌍 Geo context (country, region, currency)
- 📱 Device context (model, OS, battery, network)
- 👤 User context (segment, sessions, days active)
- 🎯 Session context (duration, screens, events)

**Event naming conventions:**

| Pattern | Example | Use For |
|---------|---------|---------|
| `noun_verbed` | `paywall_viewed` | User interactions |
| `noun_completed` | `purchase_completed` | Conversions |
| `noun_step_N` | `onboarding_step_2` | Funnel steps |
| `feature_action` | `search_used` | Feature adoption |

---

## User Management

### `ContextKit.identify()`

Identify the current user.

**Signature:**
```swift
static func identify(_ userId: String)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `userId` | `String` | ✅ | Unique user identifier |

**Example:**
```swift
ContextKit.identify("user_123")
```

**When to call:**
- After user signs up
- After user logs in
- After authentication

---

### `ContextKit.setUser()`

Set user properties for analytics.

**Signature:**
```swift
static func setUser(properties: [String: Any])
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `properties` | `[String: Any]` | ✅ | User properties dictionary |

**Example:**
```swift
ContextKit.setUser(properties: [
    "name": "John Doe",
    "email": "john@example.com",
    "plan": "premium",
    "signup_date": "2026-02-15",
    "referral_source": "product_hunt"
])
```

**Common properties:**
```swift
// After signup
ContextKit.setUser(properties: [
    "plan": "free",
    "signup_source": "organic",
    "signup_date": ISO8601DateFormatter().string(from: Date())
])

// After upgrade
ContextKit.setUser(properties: [
    "plan": "premium",
    "upgrade_date": ISO8601DateFormatter().string(from: Date()),
    "mrr": 9.99
])
```

---

### `ContextKit.setUserSegment()`

Set user segment for cohort analysis.

**Signature:**
```swift
static func setUserSegment(_ segment: String)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `segment` | `String` | ✅ | User segment label |

**Example:**
```swift
// Common segments
ContextKit.setUserSegment("free")
ContextKit.setUserSegment("premium")
ContextKit.setUserSegment("trial")
ContextKit.setUserSegment("churned")
```

**Use cases:**
- Cohort analysis (free vs paid behavior)
- A/B test groups ("control" vs "variant")
- User lifecycle stage ("new" vs "returning" vs "power_user")

---

## Screen Tracking

### `ContextKit.trackScreen()`

Track screen views and durations.

**Signature:**
```swift
static func trackScreen(_ screenName: String)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `screenName` | `String` | ✅ | Screen name (use `snake_case`) |

**Example:**

**SwiftUI:**
```swift
struct HomeView: View {
    var body: some View {
        VStack {
            Text("Home")
        }
        .onAppear {
            ContextKit.trackScreen("home")
        }
    }
}
```

**UIKit:**
```swift
class HomeViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ContextKit.trackScreen("home")
    }
}
```

**What gets tracked:**
- Screen name
- Time spent on screen (duration)
- Entry screen (first screen in session)
- Screen flow (sequence of screens)

---

## Utilities

### `ContextKit.flush()`

Force upload all queued events immediately.

**Signature:**
```swift
static func flush()
```

**Example:**
```swift
// Before app terminates
ContextKit.flush()
```

**Use cases:**
- App is about to terminate
- User logs out (want to ensure events saved)
- Critical event that must be sent immediately

**Note:** Events are automatically uploaded every 30 seconds or when batch reaches 20 events.

---

### `ContextKit.getConfig()`

Get current SDK configuration.

**Signature:**
```swift
static func getConfig() -> ContextKitConfig?
```

**Example:**
```swift
if let config = ContextKit.getConfig() {
    print("Debug mode: \(config.debugMode)")
    print("Upload interval: \(config.uploadInterval)")
}
```

---

### `ContextKit.isConfigured`

Check if SDK is configured.

**Signature:**
```swift
static var isConfigured: Bool { get }
```

**Example:**
```swift
if ContextKit.isConfigured {
    ContextKit.track("app_opened")
} else {
    print("⚠️ ContextKit not configured yet")
}
```

---

## Configuration Options

### `ContextKitConfig`

Configuration struct for customizing SDK behavior.

**Properties:**

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `apiKey` | `String` | Required | Your API key |
| `baseURL` | `String` | `https://api.contextkit.dev/v1` | API endpoint |
| `uploadInterval` | `TimeInterval` | `30.0` | Seconds between uploads |
| `maxBatchSize` | `Int` | `20` | Events per batch |
| `debugMode` | `Bool` | `false` | Enable debug overlay |
| `enableGeo` | `Bool` | `true` | Capture geo context |
| `enableDevice` | `Bool` | `true` | Capture device context |
| `enableTime` | `Bool` | `true` | Capture time context |
| `enableAutoSession` | `Bool` | `true` | Auto-track sessions |

**Example:**
```swift
let config = ContextKitConfig(
    apiKey: "ck_live_abc123",
    baseURL: "https://api.contextkit.dev/v1",
    uploadInterval: 15.0,
    maxBatchSize: 10,
    debugMode: true,
    enableGeo: true,
    enableDevice: true,
    enableTime: true,
    enableAutoSession: true
)

ContextKit.configure(apiKey: "ck_live_abc123", config: config)
```

---

## JSON Payload Examples

### Event Payload

What gets sent to the API when you call `track()`:

```json
{
  "api_key": "ck_live_abc123",
  "events": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "paywall_viewed",
      "properties": {
        "plan": "annual",
        "price": 49.99,
        "currency": "USD"
      },
      "context": {
        "time": {
          "hour": 23,
          "day_of_week": 2,
          "is_weekend": false,
          "timezone": "Asia/Tokyo",
          "local_time": "23:15",
          "day_period": "night"
        },
        "geo": {
          "country_code": "JP",
          "region": "Asia-Pacific",
          "locale_identifier": "ja_JP",
          "currency_code": "JPY",
          "language_code": "ja"
        },
        "device": {
          "model": "iPhone 15 Pro",
          "os_version": "17.4",
          "screen_width": 393.0,
          "screen_height": 852.0,
          "screen_scale": 3.0,
          "battery_level": 0.72,
          "battery_state": "unplugged",
          "network_type": "wifi",
          "is_low_power_mode": false,
          "available_disk_space": 12884901888,
          "total_memory": 8589934592
        },
        "user": {
          "user_id": "user_123",
          "segment": "premium",
          "session_count": 12,
          "days_since_install": 34,
          "custom_properties": {
            "plan": "annual",
            "signup_source": "product_hunt"
          }
        },
        "session": {
          "session_id": "a3f5e234-b123-4567-89ab-cdef01234567",
          "duration": 142.5,
          "screen_view_count": 5,
          "event_count": 8,
          "entry_screen": "home"
        },
        "sdk_version": "1.0.0",
        "captured_at": "2026-02-15T23:15:42+09:00"
      },
      "timestamp": "2026-02-15T23:15:42+09:00"
    }
  ],
  "sdk_version": "1.0.0",
  "uploaded_at": "2026-02-15T23:16:12+09:00"
}
```

### Batch Upload

Multiple events in one request:

```json
{
  "api_key": "ck_live_abc123",
  "events": [
    {
      "id": "event-1",
      "name": "app_opened",
      "properties": {},
      "context": { /* ... */ },
      "timestamp": "2026-02-15T10:00:00Z"
    },
    {
      "id": "event-2",
      "name": "paywall_viewed",
      "properties": { "plan": "annual" },
      "context": { /* ... */ },
      "timestamp": "2026-02-15T10:00:15Z"
    },
    {
      "id": "event-3",
      "name": "purchase_completed",
      "properties": { "plan": "annual", "price": 49.99 },
      "context": { /* ... */ },
      "timestamp": "2026-02-15T10:00:30Z"
    }
  ],
  "sdk_version": "1.0.0",
  "uploaded_at": "2026-02-15T10:00:45Z"
}
```

### API Response

**Success (200 OK):**
```json
{
  "success": true,
  "events_received": 3,
  "app_id": "app_abc123"
}
```

**Error (400 Bad Request):**
```json
{
  "error": "Invalid payload",
  "details": "Missing required field: api_key"
}
```

**Error (401 Unauthorized):**
```json
{
  "error": "Invalid API key"
}
```

---

## Best Practices

### Event Naming

✅ **Good:**
```swift
ContextKit.track("paywall_viewed")
ContextKit.track("purchase_completed")
ContextKit.track("onboarding_step_3")
```

❌ **Bad:**
```swift
ContextKit.track("PaywallViewed")      // PascalCase
ContextKit.track("purchase-completed") // kebab-case
ContextKit.track("viewed paywall")     // spaces
```

### Property Naming

✅ **Good:**
```swift
ContextKit.track("purchase_completed", properties: [
    "plan": "annual",          // lowercase
    "price": 49.99,            // number type
    "currency": "USD"          // short codes
])
```

❌ **Bad:**
```swift
ContextKit.track("purchase_completed", properties: [
    "Plan": "annual",          // Capitalized
    "price": "49.99",          // string instead of number
    "currency_code": "USD"     // unnecessary verbosity
])
```

### Performance

**Batch events in tight loops:**
```swift
// ❌ Bad: Track inside loop
for item in items {
    ContextKit.track("item_viewed", properties: ["id": item.id])
}

// ✅ Good: Track summary after loop
ContextKit.track("items_viewed", properties: [
    "count": items.count,
    "category": category
])
```

### Privacy

**Don't track PII:**
```swift
// ❌ Bad: PII in properties
ContextKit.track("signup", properties: [
    "email": "user@example.com",      // PII
    "phone": "+1-555-0123",           // PII
    "credit_card": "4111-1111-1111"   // NEVER!
])

// ✅ Good: Use hashed IDs
ContextKit.identify("user_\(hashedEmail)")
ContextKit.track("signup", properties: [
    "source": "organic",
    "method": "email"
])
```

---

## More Information

- **Migration Guide:** [MIGRATION_FROM_MIXPANEL.md](MIGRATION_FROM_MIXPANEL.md)
- **Best Practices:** [BEST_PRACTICES.md](BEST_PRACTICES.md)
- **Integration Examples:** [INTEGRATION_EXAMPLES.md](INTEGRATION_EXAMPLES.md)
- **Troubleshooting:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **FAQ:** [FAQ.md](FAQ.md)

---

**Questions?** Open an issue: https://github.com/acesley180604/ContextKit/issues

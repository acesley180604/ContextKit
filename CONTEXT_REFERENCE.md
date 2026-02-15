# Context Reference

Complete reference for all automatically captured context fields.

---

## Overview

Every event tracked with ContextKit is automatically enriched with a `ContextSnapshot` containing:

- ⏰ **Time Context** - When the event happened
- 🌍 **Geo Context** - Where the user is located
- 📱 **Device Context** - What device they're using
- 👤 **User Context** - Who the user is
- 🎯 **Session Context** - Current session state

**Zero configuration required.** **Zero permissions required.**

---

## Time Context

### Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `hour` | `Int` | Hour of day (24-hour format) | `23` |
| `day_of_week` | `Int` | Day of week (1=Monday, 7=Sunday) | `2` (Tuesday) |
| `is_weekend` | `Bool` | Whether it's Saturday or Sunday | `false` |
| `timezone` | `String` | IANA timezone identifier | `"Asia/Tokyo"` |
| `local_time` | `String` | Local time in HH:mm format | `"23:15"` |
| `day_period` | `String` | Period of day | `"night"` |

### Day Period Values

| Value | Time Range |
|-------|------------|
| `morning` | 5:00 - 11:59 |
| `afternoon` | 12:00 - 16:59 |
| `evening` | 17:00 - 20:59 |
| `night` | 21:00 - 4:59 |

### Example JSON

```json
{
  "time": {
    "hour": 23,
    "day_of_week": 2,
    "is_weekend": false,
    "timezone": "Asia/Tokyo",
    "local_time": "23:15",
    "day_period": "night"
  }
}
```

### Use Cases

**Time-based insights:**
- "Users convert 2.3x better in the evening vs morning"
- "Japan users are most active 21:00-23:00 local time"
- "Weekend conversion is 40% lower than weekdays"

**Optimization:**
- Schedule push notifications for peak engagement times
- Show time-limited offers during high-conversion periods
- Adjust UI based on time of day (dark mode hints)

---

## Geo Context

### Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `country_code` | `String` | ISO 3166-1 alpha-2 country code | `"JP"` |
| `region` | `String` | Geographic region | `"Asia-Pacific"` |
| `locale_identifier` | `String` | Locale identifier | `"ja_JP"` |
| `currency_code` | `String` | ISO 4217 currency code | `"JPY"` |
| `language_code` | `String` | ISO 639-1 language code | `"ja"` |

### Region Values

Computed from country code:

- `"Asia-Pacific"` - China, Japan, Korea, Taiwan, Hong Kong, Singapore, Thailand, Vietnam, Indonesia, Malaysia, Philippines, India, Australia, New Zealand
- `"Europe"` - UK, Germany, France, Italy, Spain, Netherlands, Sweden, Norway, Denmark, Finland, Poland, Switzerland, Austria, Belgium, Ireland, Portugal, Czech Republic, Greece, Romania, Hungary
- `"North America"` - United States, Canada, Mexico
- `"South America"` - Brazil, Argentina, Chile, Colombia, Peru, Venezuela, Ecuador, Bolivia, Paraguay, Uruguay
- `"Middle East"` - UAE, Saudi Arabia, Israel, Turkey, Egypt, Qatar, Kuwait, Bahrain, Oman, Jordan, Lebanon
- `"Africa"` - South Africa, Nigeria, Kenya, Ghana, Tanzania, Uganda, Zimbabwe, Ethiopia, Morocco, Algeria, Tunisia
- `"Other"` - All other countries

### Example JSON

```json
{
  "geo": {
    "country_code": "JP",
    "region": "Asia-Pacific",
    "locale_identifier": "ja_JP",
    "currency_code": "JPY",
    "language_code": "ja"
  }
}
```

### How It Works

**Source:** `Locale.current.region`

- Based on device language/region settings
- **NOT GPS** - no location permission required
- Country-level accuracy only (not city-level)
- Privacy-friendly

### Use Cases

**Geo-based insights:**
- "Germany converts 38% better than US"
- "Japan users have 2.3x longer sessions"
- "Asia-Pacific users prefer weekend engagement"

**Localization:**
- Show prices in user's currency
- A/B test messages by region
- Adjust content for cultural preferences

**Market analysis:**
- Which markets to expand to
- Regional conversion patterns
- Currency-specific pricing optimization

---

## Device Context

### Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `model` | `String` | Device model name | `"iPhone 15 Pro"` |
| `os_version` | `String` | iOS version | `"17.4"` |
| `screen_width` | `Double` | Screen width in points | `393.0` |
| `screen_height` | `Double` | Screen height in points | `852.0` |
| `screen_scale` | `Double` | Screen scale factor | `3.0` |
| `battery_level` | `Double` | Battery level (0.0-1.0, -1 if unavailable) | `0.72` |
| `battery_state` | `String` | Battery charging state | `"unplugged"` |
| `network_type` | `String` | Network connection type | `"wifi"` |
| `is_low_power_mode` | `Bool` | Whether low power mode is enabled | `false` |
| `available_disk_space` | `Int64` | Available storage in bytes | `12884901888` |
| `total_memory` | `UInt64` | Total RAM in bytes | `8589934592` |

### Battery State Values

| Value | Description |
|-------|-------------|
| `unknown` | Battery state unknown |
| `unplugged` | Not charging |
| `charging` | Currently charging |
| `full` | Fully charged |

### Network Type Values

| Value | Description |
|-------|-------------|
| `unknown` | Network type unknown |
| `wifi` | WiFi connection |
| `cellular` | Cellular data |
| `offline` | No connection |

### Example JSON

```json
{
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
  }
}
```

### Device Model Mapping

Common models:

- `"iPhone 15 Pro"` - iPhone16,1
- `"iPhone 15 Pro Max"` - iPhone16,2
- `"iPhone 15"` - iPhone16,3
- `"iPhone 15 Plus"` - iPhone16,4
- `"iPhone 14 Pro"` - iPhone15,2
- `"iPhone 14 Pro Max"` - iPhone15,3
- `"iPad Air (4th gen)"` - iPad13,1
- `"iPad mini (6th gen)"` - iPad14,1

### Use Cases

**Device-based insights:**
- "iPhone 15 Pro users convert 1.8x vs iPhone 13"
- "iPad users have 4.2x longer sessions"
- "Low battery users exit 60% faster"

**Optimization:**
- Reduce animations on older devices
- Optimize for most common screen sizes
- Defer non-critical work when battery low
- Show "offline mode" features when offline

**UX improvements:**
- Simplify UI when battery is low
- Cache more content for cellular users
- Adjust video quality based on network

---

## User Context

### Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `user_id` | `String?` | Developer-provided user ID | `"user_123"` |
| `segment` | `String?` | User segment | `"premium"` |
| `session_count` | `Int` | Total sessions | `12` |
| `days_since_install` | `Int` | Days since first app launch | `34` |
| `custom_properties` | `Object` | Custom user properties | `{"plan": "annual"}` |

### Example JSON

```json
{
  "user": {
    "user_id": "user_123",
    "segment": "premium",
    "session_count": 12,
    "days_since_install": 34,
    "custom_properties": {
      "plan": "annual",
      "signup_source": "product_hunt"
    }
  }
}
```

### How to Set

```swift
// Identify user
ContextKit.identify("user_123")

// Set segment
ContextKit.setUserSegment("premium")

// Set custom properties
ContextKit.setUser(properties: [
    "plan": "annual",
    "signup_source": "product_hunt"
])
```

### Use Cases

**User segmentation:**
- "Premium users engage 3.2x more than free"
- "Users who signed up via Product Hunt convert 2.1x better"
- "New users (days < 7) need more onboarding hints"

**Cohort analysis:**
- Compare free vs premium behavior
- Track conversion by signup source
- Measure retention by user age

---

## Session Context

### Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `session_id` | `String` | Unique session identifier | `"a3f5e234..."` |
| `duration` | `Double` | Session duration in seconds | `142.5` |
| `screen_view_count` | `Int` | Screens viewed this session | `5` |
| `event_count` | `Int` | Events tracked this session | `8` |
| `entry_screen` | `String?` | First screen in session | `"home"` |

### Example JSON

```json
{
  "session": {
    "session_id": "a3f5e234-b123-4567-89ab-cdef01234567",
    "duration": 142.5,
    "screen_view_count": 5,
    "event_count": 8,
    "entry_screen": "home"
  }
}
```

### How It Works

**Session start:**
- App enters foreground
- New UUID generated
- Entry screen recorded

**Session end:**
- App enters background
- Duration calculated
- Session data persisted

**Auto-tracked:**
- No configuration needed
- Enabled by default
- Can be disabled with `enableAutoSession: false`

### Use Cases

**Session analysis:**
- "Users with 5+ screen views convert 2.4x better"
- "Average session duration: 4.2 minutes"
- "Entry screen affects conversion: direct link users convert 1.8x"

**Funnel optimization:**
- Track screen flow through session
- Identify drop-off points
- Optimize navigation paths

---

## Complete Example

Here's a complete event with all context:

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "purchase_completed",
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
```

---

## Privacy Notes

### What Requires Permissions

**ContextKit requires ZERO permissions:**
- ❌ No location tracking (uses locale, not GPS)
- ❌ No App Tracking Transparency prompt
- ❌ No contacts access
- ❌ No camera/photos access
- ❌ No special entitlements

### What's Collected

**Automatically:**
- Time (from system clock)
- Country (from locale settings)
- Device model (from public APIs)
- App usage (what you explicitly track)

**Only if you provide:**
- User ID (via `identify()`)
- User properties (via `setUser()`)
- Custom event properties

**Never collected:**
- GPS coordinates
- Precise location
- Contact information (unless you track it - don't!)
- Personal identifiable information

---

## More Information

- **API Reference:** [API_REFERENCE.md](API_REFERENCE.md)
- **Best Practices:** [BEST_PRACTICES.md](BEST_PRACTICES.md)
- **Privacy:** [FAQ.md](FAQ.md#privacy--security)

---

**Questions about context?** Open an issue: https://github.com/acesley180604/ContextKit/issues

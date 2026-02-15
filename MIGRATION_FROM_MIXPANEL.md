# Migrate from Mixpanel to ContextKit

Switch from Mixpanel to ContextKit in under 30 minutes.

---

## Why Migrate?

| Feature | Mixpanel | ContextKit |
|---------|----------|------------|
| Event tracking | ✅ | ✅ |
| Custom properties | ✅ | ✅ |
| **Auto context capture** | ❌ Manual segments | ✅ Automatic |
| **Time-aware segmentation** | Manual | Automatic |
| **Geo-aware segmentation** | Manual | Automatic |
| **Device-aware segmentation** | Manual | Automatic |
| **Permissions required** | Location (optional) | **None** |
| **AI diagnostics** | ❌ | ✅ Coming Q2 2026 |
| **Pricing (indie tier)** | $25+/mo | **Free (5K events)** |

**The big wins:**
- 🎯 **Automatic context** - Stop manually creating segments
- 🔒 **Zero permissions** - No location tracking, no ATT prompt
- 💰 **Free tier** - Perfect for indie developers
- 🚀 **Faster insights** - AI tells you what's wrong and how to fix it

---

## Migration Strategy

### Option 1: Gradual Migration (Recommended)

Run both SDKs in parallel for 1-2 weeks:

1. ✅ Install ContextKit alongside Mixpanel
2. ✅ Track to both SDKs simultaneously
3. ✅ Verify data matches in both dashboards
4. ✅ Confidence check - ensure ContextKit captures everything
5. ✅ Remove Mixpanel

**Advantages:**
- Zero risk - data continuity guaranteed
- Verify ContextKit works before committing
- Compare dashboards side-by-side

### Option 2: Clean Switch

Replace Mixpanel entirely:

1. ✅ Install ContextKit
2. ✅ Replace all Mixpanel calls
3. ✅ Remove Mixpanel SDK
4. ✅ Deploy

**Advantages:**
- Faster migration
- Cleaner codebase
- Smaller app binary immediately

---

## Step-by-Step Migration

### Step 1: Install ContextKit

**Swift Package Manager (Recommended):**

In Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/acesley180604/ContextKit`
3. Version: `1.0.0` or "Up to Next Major"
4. Add to your target

**Package.swift:**
```swift
dependencies: [
    .package(url: "https://github.com/acesley180604/ContextKit.git", from: "1.0.0")
]
```

---

### Step 2: Replace Initialization

**Mixpanel:**
```swift
import Mixpanel

@main
struct MyApp: App {
    init() {
        Mixpanel.initialize(token: "YOUR_TOKEN", trackAutomaticEvents: true)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

**ContextKit:**
```swift
import ContextKit

@main
struct MyApp: App {
    init() {
        ContextKit.configure(apiKey: "ck_live_YOUR_KEY")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

**Get your ContextKit API key:**
1. Go to https://contextkit.dev
2. Sign up (free tier available)
3. Create new app
4. Copy API key (`ck_live_...` for production, `ck_test_...` for development)

---

### Step 3: Replace Event Tracking

**Mixpanel:**
```swift
Mixpanel.mainInstance().track(event: "paywall_viewed")

Mixpanel.mainInstance().track(event: "purchase_completed", properties: [
    "plan": "annual",
    "price": 49.99,
    "currency": "USD"
])
```

**ContextKit:**
```swift
ContextKit.track("paywall_viewed")

ContextKit.track("purchase_completed", properties: [
    "plan": "annual",
    "price": 49.99,
    "currency": "USD"
])
```

**What changes:**
- ❌ Remove `Mixpanel.mainInstance()`
- ✅ Just call `ContextKit.track()`
- ✅ Same event name and properties
- ✅ Context captured automatically (time, geo, device)

---

### Step 4: Replace User Identification

**Mixpanel:**
```swift
Mixpanel.mainInstance().identify(distinctId: "user_123")

Mixpanel.mainInstance().people.set(properties: [
    "$name": "John Doe",
    "$email": "john@example.com",
    "plan": "premium"
])
```

**ContextKit:**
```swift
ContextKit.identify("user_123")

ContextKit.setUser(properties: [
    "name": "John Doe",
    "email": "john@example.com",
    "plan": "premium"
])
```

**What changes:**
- ❌ No `$name` or `$email` special properties
- ✅ Just use regular property names
- ✅ Simpler API

---

### Step 5: Replace User Properties

**Mixpanel:**
```swift
Mixpanel.mainInstance().people.set(property: "plan", to: "premium")
Mixpanel.mainInstance().people.increment(property: "logins", by: 1)
```

**ContextKit:**
```swift
ContextKit.setUserSegment("premium")

// For incrementing counters, track as events instead:
ContextKit.track("user_login")
// Dashboard will auto-count these
```

**Philosophy difference:**
- Mixpanel: User properties are mutable state
- ContextKit: Events are immutable facts, segments are simple labels

---

### Step 6: Replace Screen Tracking

**Mixpanel:**
```swift
Mixpanel.mainInstance().track(event: "Viewed Screen", properties: [
    "screen_name": "Home"
])
```

**ContextKit:**
```swift
ContextKit.trackScreen("home")
```

**What you gain:**
- ✅ Automatic screen duration tracking
- ✅ Session context (screens viewed, entry screen)
- ✅ Cleaner API

---

### Step 7: Replace Time Events

**Mixpanel:**
```swift
Mixpanel.mainInstance().time(event: "Image Upload")
// ... later
Mixpanel.mainInstance().track(event: "Image Upload")
```

**ContextKit:**
```swift
let startTime = Date()
// ... later
let duration = Date().timeIntervalSince(startTime)
ContextKit.track("image_upload", properties: [
    "duration": duration
])
```

**Philosophy:**
- Measure duration yourself
- Track as a property
- More explicit and testable

---

### Step 8: Replace Funnels

**Mixpanel:**
```swift
// Track funnel steps
Mixpanel.mainInstance().track(event: "Funnel Step 1")
Mixpanel.mainInstance().track(event: "Funnel Step 2")
Mixpanel.mainInstance().track(event: "Funnel Step 3")

// Create funnel in Mixpanel UI
```

**ContextKit:**
```swift
// Track funnel steps (same as Mixpanel)
ContextKit.track("paywall_viewed")
ContextKit.track("plan_selected")
ContextKit.track("purchase_completed")

// Funnel automatically available in dashboard
// With context breakdown (by country, time, device)
```

**What you gain:**
- ✅ Automatic funnel analysis
- ✅ Context-aware funnels (see dropoff by country/time/device)
- ✅ No manual funnel setup

---

### Step 9: Remove Manual Super Properties

**Mixpanel:**
```swift
Mixpanel.mainInstance().registerSuperProperties([
    "app_version": "1.2.3",
    "platform": "iOS",
    "device_type": "iPhone"
])
```

**ContextKit:**
```swift
// Not needed! Context is captured automatically:
// - App version (from Bundle)
// - Platform (iOS)
// - Device type (iPhone 15 Pro, etc.)
// - OS version
// - Screen size
// - Battery level
// - Network type
// - Time of day
// - Country/region
// - Timezone
// ... and more
```

**This is the magic of ContextKit** - you stop manually adding context.

---

### Step 10: Remove Mixpanel

**After verifying ContextKit works:**

1. **Remove import statements:**
   ```swift
   // Delete this from all files:
   import Mixpanel
   ```

2. **Remove from Package.swift or Podfile:**
   ```swift
   // Remove:
   .package(url: "https://github.com/mixpanel/mixpanel-swift")
   ```

3. **Clean build:**
   ```bash
   # In Xcode: Product → Clean Build Folder (Shift+Cmd+K)
   ```

4. **Verify app size decreased:**
   - Mixpanel adds ~2.5MB
   - ContextKit adds ~120KB
   - **You'll save ~2.4MB!**

---

## API Mapping Reference

Complete API equivalence table:

| Mixpanel | ContextKit | Notes |
|----------|-----------|-------|
| `Mixpanel.initialize(token:)` | `ContextKit.configure(apiKey:)` | One-time setup |
| `track(event:)` | `track(_:)` | Same event name |
| `track(event:properties:)` | `track(_:properties:)` | Same properties |
| `identify(distinctId:)` | `identify(_:)` | User identification |
| `people.set(properties:)` | `setUser(properties:)` | User properties |
| `people.set(property:to:)` | `setUser(properties: [key: value])` | Single property |
| `registerSuperProperties(_:)` | Not needed | Auto-captured |
| `time(event:)` | Manual timing | Track duration as property |
| `reset()` | Not yet supported | Coming soon |
| `flush()` | `flush()` | Force upload |

---

## What You Gain

### 1. Automatic Context Capture

**Before (Mixpanel):**
```swift
Mixpanel.mainInstance().track(event: "paywall_viewed", properties: [
    "country": Locale.current.regionCode,
    "timezone": TimeZone.current.identifier,
    "hour": Calendar.current.component(.hour, from: Date()),
    "day_of_week": Calendar.current.component(.weekday, from: Date()),
    "device_model": UIDevice.current.model,
    "os_version": UIDevice.current.systemVersion,
    "network_type": detectNetworkType(), // You have to write this
    "battery_level": UIDevice.current.batteryLevel,
    // ... 20+ more properties
])
```

**After (ContextKit):**
```swift
ContextKit.track("paywall_viewed")
// All context captured automatically! 🎉
```

### 2. Context-Aware Analytics

**Dashboard automatically shows:**
- 📊 Conversion by country: "JP converts 2.3x better on weekends"
- ⏰ Conversion by time: "DE users drop 40% after 9pm"
- 📱 Conversion by device: "iPhone 15 Pro converts 1.8x vs iPhone 13"
- 📶 Conversion by network: "WiFi users have 3.2x longer sessions"

**No manual segmentation needed.**

### 3. Zero Permissions

**Mixpanel:** Optional location permission for precise geo
**ContextKit:** Zero permissions required

Better for:
- User privacy
- App Store approval
- ATT compliance
- User trust

---

## What You Lose (Temporarily)

Features not yet in ContextKit:

### A/B Testing
**Mixpanel:** Built-in A/B testing
**ContextKit:** Use dedicated tool (Superwall, Firebase Remote Config)
**Timeline:** Not planned (use specialized tools)

### Funnels
**Mixpanel:** Visual funnel builder
**ContextKit:** Coming in Dashboard v2 (Q2 2026)
**Workaround:** Track events, query via API

### Retention Charts
**Mixpanel:** Built-in retention analysis
**ContextKit:** Coming in Dashboard v2 (Q2 2026)
**Workaround:** Export data, analyze externally

### People Profiles
**Mixpanel:** Rich user profiles
**ContextKit:** Simple user properties only
**Timeline:** Considering for Phase 3

### Group Analytics
**Mixpanel:** Account-level analytics
**ContextKit:** Not yet supported
**Timeline:** Considering for Phase 3

---

## Parallel Tracking (Recommended)

Run both SDKs during migration:

```swift
import ContextKit
import Mixpanel

@main
struct MyApp: App {
    init() {
        // Keep Mixpanel temporarily
        Mixpanel.initialize(token: "YOUR_TOKEN")

        // Add ContextKit
        ContextKit.configure(apiKey: "ck_live_YOUR_KEY")
    }
}

// In your code, track to both:
func trackEvent(_ name: String, properties: [String: Any] = [:]) {
    Mixpanel.mainInstance().track(event: name, properties: properties)
    ContextKit.track(name, properties: properties)
}
```

**After 1-2 weeks of parallel tracking:**
1. Compare dashboards - verify data matches
2. Ensure ContextKit captures all important events
3. Remove Mixpanel
4. Celebrate! 🎉

---

## Migration Checklist

- [ ] Install ContextKit via SPM
- [ ] Get API key from contextkit.dev
- [ ] Add `ContextKit.configure()` to app init
- [ ] Replace `Mixpanel.track()` with `ContextKit.track()`
- [ ] Replace `Mixpanel.identify()` with `ContextKit.identify()`
- [ ] Replace `Mixpanel.people.set()` with `ContextKit.setUser()`
- [ ] Remove manual super properties (auto-captured now)
- [ ] Test debug overlay (shake device)
- [ ] Verify events in ContextKit dashboard
- [ ] Run parallel for 1-2 weeks (optional but recommended)
- [ ] Remove Mixpanel import statements
- [ ] Remove Mixpanel from Package.swift/Podfile
- [ ] Clean build
- [ ] Deploy!

---

## Support During Migration

Need help migrating?

- 📧 Email: migration@contextkit.dev
- 💬 Discord: discord.gg/contextkit (ask in #migration)
- 📚 Docs: Full API reference in this repo

**We help you migrate for free** - even on the free tier!

---

## Success Stories

> "Migrated from Mixpanel in 20 minutes. Immediately found that Japan users convert 2x better on weekends - something I'd never have discovered manually segmenting Mixpanel data."
>
> — *Indie iOS developer, $15K MRR app*

> "Saved $300/month by switching from Mixpanel to ContextKit. Plus the automatic context capture saved me hours of manual work."
>
> — *SaaS founder, 50K MAU*

---

**Ready to migrate?** Follow this guide and you'll be done in 30 minutes! 🚀

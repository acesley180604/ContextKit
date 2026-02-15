# Best Practices

Guidelines for getting the most value from ContextKit.

---

## Table of Contents

- [Event Naming](#event-naming)
- [Property Naming](#property-naming)
- [What to Track](#what-to-track)
- [What NOT to Track](#what-not-to-track)
- [Performance](#performance)
- [Privacy](#privacy)
- [Testing](#testing)

---

## Event Naming

### Use snake_case

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

**Why:** Consistency makes querying easier. snake_case is the standard in analytics.

---

### Use Past Tense for Completed Actions

✅ **Good:**
```swift
ContextKit.track("purchase_completed")
ContextKit.track("video_watched")
ContextKit.track("form_submitted")
```

❌ **Bad:**
```swift
ContextKit.track("purchase_complete")  // Present tense
ContextKit.track("watching_video")     // Progressive
ContextKit.track("submit_form")        // Infinitive
```

**Why:** Events represent things that already happened. Past tense is clearest.

---

### Be Specific but Concise

✅ **Good:**
```swift
ContextKit.track("paywall_viewed")
ContextKit.track("annual_plan_selected")
ContextKit.track("payment_failed")
```

❌ **Bad:**
```swift
ContextKit.track("event")                          // Too vague
ContextKit.track("user_viewed_the_paywall_screen") // Too verbose
ContextKit.track("pv")                             // Too cryptic
```

**Why:** Names should be self-documenting. You'll thank yourself in 6 months.

---

### Follow Consistent Patterns

**Noun + Action Pattern:**

✅ **Good:**
```swift
ContextKit.track("paywall_viewed")
ContextKit.track("paywall_dismissed")
ContextKit.track("paywall_converted")
```

**Funnel Step Pattern:**

✅ **Good:**
```swift
ContextKit.track("onboarding_step_1")
ContextKit.track("onboarding_step_2")
ContextKit.track("onboarding_step_3")
ContextKit.track("onboarding_completed")
```

**Feature Usage Pattern:**

✅ **Good:**
```swift
ContextKit.track("search_used")
ContextKit.track("export_used")
ContextKit.track("share_used")
```

---

## Property Naming

### Use lowercase

✅ **Good:**
```swift
ContextKit.track("purchase_completed", properties: [
    "plan": "annual",
    "price": 49.99
])
```

❌ **Bad:**
```swift
ContextKit.track("purchase_completed", properties: [
    "Plan": "annual",      // Capitalized
    "PRICE": 49.99         // All caps
])
```

---

### Use Correct Types

✅ **Good:**
```swift
ContextKit.track("purchase_completed", properties: [
    "plan": "annual",          // String
    "price": 49.99,            // Double
    "is_trial": false,         // Bool
    "quantity": 1              // Int
])
```

❌ **Bad:**
```swift
ContextKit.track("purchase_completed", properties: [
    "plan": "annual",
    "price": "49.99",          // String instead of number
    "is_trial": "false",       // String instead of bool
    "quantity": "1"            // String instead of int
])
```

**Why:** Correct types enable mathematical operations in analytics (sum, average, etc.).

---

### Be Concise

✅ **Good:**
```swift
properties: [
    "plan": "annual",
    "price": 49.99,
    "currency": "USD"
]
```

❌ **Bad:**
```swift
properties: [
    "selected_plan_type": "annual",
    "total_price_in_dollars": 49.99,
    "currency_code_iso_4217": "USD"
]
```

**Why:** Shorter names = less data = faster uploads.

---

## What to Track

### ✅ Track User Flows

Track the complete user journey:

```swift
// Onboarding
ContextKit.track("app_opened")
ContextKit.trackScreen("welcome")
ContextKit.track("onboarding_started")
ContextKit.trackScreen("onboarding_step_1")
ContextKit.trackScreen("onboarding_step_2")
ContextKit.trackScreen("onboarding_step_3")
ContextKit.track("onboarding_completed")

// Paywall
ContextKit.trackScreen("paywall")
ContextKit.track("paywall_viewed")
ContextKit.track("plan_selected", properties: ["plan": "annual"])
ContextKit.track("purchase_initiated")
ContextKit.track("purchase_completed", properties: [
    "plan": "annual",
    "price": 49.99
])
```

**Why:** See where users drop off. Optimize the funnel.

---

### ✅ Track Key Conversions

```swift
// Sign up
ContextKit.track("signup_completed", properties: [
    "method": "email"
])

// Purchase
ContextKit.track("purchase_completed", properties: [
    "plan": "annual",
    "revenue": 49.99,
    "currency": "USD"
])

// Subscription renewal
ContextKit.track("subscription_renewed", properties: [
    "plan": "annual",
    "is_auto_renew": true
])

// Referrals
ContextKit.track("referral_completed", properties: [
    "code": "FRIEND2024"
])
```

**Why:** Revenue events are critical. Track them religiously.

---

### ✅ Track Feature Adoption

```swift
ContextKit.track("feature_used", properties: [
    "feature": "export"
])

ContextKit.track("feature_used", properties: [
    "feature": "collaboration"
])

ContextKit.track("feature_discovered", properties: [
    "feature": "templates",
    "method": "tooltip"
])
```

**Why:** Know what features users actually use. Kill unused features.

---

### ✅ Track Errors and Failures

```swift
ContextKit.track("api_error", properties: [
    "endpoint": "/api/users",
    "status_code": 500,
    "error": "Internal server error"
])

ContextKit.track("purchase_failed", properties: [
    "plan": "annual",
    "error": "Payment declined"
])

ContextKit.track("import_failed", properties: [
    "format": "csv",
    "error": "Invalid format"
])
```

**Why:** Catch issues before users complain. Improve reliability.

---

## What NOT to Track

### ❌ Don't Track PII

**Never track:**
- Email addresses
- Phone numbers
- Credit card numbers
- Social security numbers
- Passwords (obviously!)
- IP addresses (captured server-side only)

❌ **Bad:**
```swift
ContextKit.track("signup_completed", properties: [
    "email": "user@example.com",    // PII!
    "phone": "+1-555-0123",         // PII!
    "ip_address": "192.168.1.1"     // PII!
])
```

✅ **Good:**
```swift
ContextKit.identify("user_123")  // Hashed ID
ContextKit.track("signup_completed", properties: [
    "method": "email",
    "domain": "gmail.com"  // OK: domain only
])
```

**Why:** Privacy compliance (GDPR, CCPA). User trust.

---

### ❌ Don't Track User-Generated Content

❌ **Bad:**
```swift
ContextKit.track("note_created", properties: [
    "content": noteText  // Don't track actual note content!
])
```

✅ **Good:**
```swift
ContextKit.track("note_created", properties: [
    "length": noteText.count,
    "has_images": containsImages,
    "word_count": wordCount
])
```

**Why:** Privacy. Also, user content is high-cardinality (bad for analytics).

---

### ❌ Don't Track Too Frequently

❌ **Bad:**
```swift
// Track on every keystroke!
func textDidChange(_ text: String) {
    ContextKit.track("text_changed", properties: [
        "length": text.count
    ])
}
```

✅ **Good:**
```swift
// Track when user finishes typing
func textEditingDidEnd() {
    ContextKit.track("text_edited", properties: [
        "final_length": text.count,
        "time_spent": editDuration
    ])
}
```

**Why:** Reduces noise. Saves bandwidth. Better performance.

---

### ❌ Don't Track High-Cardinality Data

❌ **Bad:**
```swift
ContextKit.track("page_viewed", properties: [
    "url": "https://example.com/users/12345/posts/67890"  // Unique every time!
])
```

✅ **Good:**
```swift
ContextKit.track("page_viewed", properties: [
    "page_type": "post",
    "user_type": "author"
])
```

**Why:** High-cardinality = millions of unique values = hard to analyze.

---

## Performance

### Batch Events in Loops

❌ **Bad:**
```swift
for item in items {
    ContextKit.track("item_viewed", properties: [
        "id": item.id
    ])
}
```

✅ **Good:**
```swift
ContextKit.track("items_viewed", properties: [
    "count": items.count,
    "category": category
])
```

---

### Use Flush Sparingly

❌ **Bad:**
```swift
ContextKit.track("event_1")
ContextKit.flush()  // Don't flush after every event!
ContextKit.track("event_2")
ContextKit.flush()
```

✅ **Good:**
```swift
// Let SDK batch automatically
ContextKit.track("event_1")
ContextKit.track("event_2")

// Only flush when critical
func applicationWillTerminate() {
    ContextKit.flush()
}
```

---

### Configure Sensible Batch Settings

✅ **Good:**
```swift
let config = ContextKitConfig(
    apiKey: "ck_live_xxx",
    uploadInterval: 30.0,   // Default
    maxBatchSize: 20        // Default
)
```

**For high-traffic apps:**
```swift
let config = ContextKitConfig(
    apiKey: "ck_live_xxx",
    uploadInterval: 60.0,   // Less frequent
    maxBatchSize: 50        // Larger batches
)
```

---

## Privacy

### Ask for Minimal Data

✅ **Good:**
```swift
// Only track what you need
ContextKit.identify(hashedUserId)
ContextKit.setUserSegment("premium")
```

❌ **Bad:**
```swift
// Tracking everything "just in case"
ContextKit.setUser(properties: [
    "name": user.name,
    "email": user.email,
    "age": user.age,
    "gender": user.gender,
    "address": user.address,
    // ... stop!
])
```

---

### Use Hashed IDs

✅ **Good:**
```swift
import CryptoKit

func hashEmail(_ email: String) -> String {
    let data = Data(email.utf8)
    let hashed = SHA256.hash(data: data)
    return hashed.compactMap { String(format: "%02x", $0) }.joined()
}

let userId = "user_\(hashEmail(userEmail))"
ContextKit.identify(userId)
```

---

### Respect User Preferences

```swift
class AnalyticsManager {
    static var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "analytics_enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "analytics_enabled") }
    }

    static func track(_ event: String, properties: [String: Any] = [:]) {
        guard isEnabled else { return }
        ContextKit.track(event, properties: properties)
    }
}

// In settings:
Toggle("Analytics", isOn: $analyticsEnabled)
    .onChange(of: analyticsEnabled) { old, new in
        AnalyticsManager.isEnabled = new
    }
```

---

## Testing

### Use Test API Key in Development

```swift
@main
struct MyApp: App {
    init() {
        #if DEBUG
        ContextKit.configure(apiKey: "ck_test_development_12345")
        #else
        ContextKit.configure(apiKey: "ck_live_production_key")
        #endif
    }
}
```

---

### Enable Debug Mode in Development

```swift
#if DEBUG
let config = ContextKitConfig(
    apiKey: "ck_test_xxx",
    debugMode: true  // Shake to see events
)
ContextKit.configure(apiKey: "ck_test_xxx", config: config)
#endif
```

---

### Write Unit Tests

```swift
import XCTest
@testable import MyApp

class AnalyticsTests: XCTestCase {

    func testPurchaseTracking() {
        // Your purchase logic
        let result = performPurchase(plan: "annual")

        // Verify tracking called
        // (You'll need to mock ContextKit for this)
        XCTAssertTrue(result.success)
    }
}
```

---

### Validate Event Names

```swift
enum AnalyticsEvent: String {
    case appOpened = "app_opened"
    case paywallViewed = "paywall_viewed"
    case purchaseCompleted = "purchase_completed"

    func track(properties: [String: Any] = [:]) {
        ContextKit.track(self.rawValue, properties: properties)
    }
}

// Usage:
AnalyticsEvent.paywallViewed.track(properties: ["plan": "annual"])

// Benefit: Compile-time checking of event names!
```

---

## Context Utilization

### Trust Automatic Context

❌ **Don't do this:**
```swift
ContextKit.track("purchase_completed", properties: [
    "country": Locale.current.regionCode,
    "hour": Calendar.current.component(.hour, from: Date()),
    "device": UIDevice.current.model,
    // ... ContextKit already captures this!
])
```

✅ **Do this:**
```swift
ContextKit.track("purchase_completed", properties: [
    "plan": "annual",
    "price": 49.99
])
// Context captured automatically!
```

---

### Use Context in Queries

Once in dashboard, analyze by context:

- **By country:** "Which countries convert best?"
- **By time:** "What time of day do users purchase?"
- **By device:** "Do iPhone 15 Pro users behave differently?"
- **By day:** "Are weekends better than weekdays?"

---

## Documentation

### Document Your Events

Create an event catalog:

```swift
/**
 * Analytics Event Catalog
 *
 * ## Onboarding
 * - `onboarding_started`: User begins onboarding
 * - `onboarding_step_N`: User completes step N
 * - `onboarding_completed`: User finishes onboarding
 *
 * ## Paywall
 * - `paywall_viewed`: Paywall shown
 *   Properties: { plan: String }
 * - `purchase_completed`: Purchase successful
 *   Properties: { plan: String, price: Double, revenue: Double }
 */
```

---

## Checklist

Before deploying:

- [ ] All events use `snake_case` naming
- [ ] No PII in event properties
- [ ] Using test API key in development
- [ ] Using production API key in release
- [ ] Debug mode disabled in production
- [ ] Critical conversions tracked (signup, purchase)
- [ ] Error tracking in place
- [ ] Funnel steps tracked
- [ ] User identification implemented
- [ ] Privacy policy updated

---

## More Resources

- **API Reference:** [API_REFERENCE.md](API_REFERENCE.md)
- **Integration Examples:** [INTEGRATION_EXAMPLES.md](INTEGRATION_EXAMPLES.md)
- **Troubleshooting:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **FAQ:** [FAQ.md](FAQ.md)

---

**Follow these practices and you'll have clean, actionable analytics!** 📊

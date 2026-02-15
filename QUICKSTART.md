# ContextKit Quick Start Guide

Get up and running with ContextKit in under 5 minutes.

## Installation

### Swift Package Manager (Recommended)

#### Option 1: Xcode UI

1. Open your project in Xcode
2. File → Add Package Dependencies
3. Enter package URL: `https://github.com/contextkit/contextkit`
4. Select version: `1.0.0` or `Up to Next Major`
5. Add to your app target
6. Click "Add Package"

#### Option 2: Package.swift

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/contextkit/contextkit.git", from: "1.0.0")
]
```

Then add to your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["ContextKit"]
)
```

## Configuration

### Step 1: Get Your API Key

1. Visit [contextkit.dev](https://contextkit.dev)
2. Sign up for a free account
3. Create a new app
4. Copy your API key (format: `ck_live_xxx`)

### Step 2: Configure SDK

#### SwiftUI App

```swift
import SwiftUI
import ContextKit

@main
struct YourApp: App {
    init() {
        // Configure ContextKit on app launch
        ContextKit.configure(apiKey: "ck_live_xxx")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

#### UIKit AppDelegate

```swift
import UIKit
import ContextKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Configure ContextKit
        ContextKit.configure(apiKey: "ck_live_xxx")
        return true
    }
}
```

### Step 3: Track Events

```swift
import ContextKit

// Track simple event
ContextKit.track("app_opened")

// Track with properties
ContextKit.track("paywall_viewed", properties: [
    "plan": "annual",
    "price": 49.99
])

// Track screen views
ContextKit.trackScreen("home")
ContextKit.trackScreen("settings")

// Identify user
ContextKit.identify("user_123")

// Set user properties
ContextKit.setUser(properties: [
    "plan": "premium",
    "signup_date": "2026-02-15"
])
```

## Debug Mode

Enable debug mode during development to see events in real-time:

```swift
ContextKit.configure(
    apiKey: "ck_test_xxx",
    config: .init(debugMode: true)
)
```

Then shake your device to open the debug overlay!

## Advanced Configuration

```swift
import ContextKit

let config = ContextKitConfig(
    apiKey: "ck_live_xxx",
    uploadInterval: 30.0,        // Upload every 30 seconds
    maxBatchSize: 20,             // Upload when 20 events queued
    debugMode: false,             // Disable debug overlay
    enableGeo: true,              // Capture geo context
    enableDevice: true,           // Capture device context
    enableTime: true,             // Capture time context
    enableAutoSession: true       // Auto-track sessions
)

ContextKit.configure(apiKey: "ck_live_xxx", config: config)
```

## Common Use Cases

### Track Paywall Conversions

```swift
// User views paywall
ContextKit.track("paywall_viewed")

// User selects plan
ContextKit.track("plan_selected", properties: [
    "plan": "annual"
])

// User completes purchase
ContextKit.track("purchase_completed", properties: [
    "plan": "annual",
    "price": 49.99,
    "revenue": 49.99
])
```

### Track Onboarding

```swift
// User starts onboarding
ContextKit.track("onboarding_started")

// Track each step
ContextKit.trackScreen("onboarding_step_1")
ContextKit.trackScreen("onboarding_step_2")
ContextKit.trackScreen("onboarding_step_3")

// User completes onboarding
ContextKit.track("onboarding_completed")
```

### Track User Authentication

```swift
// User signs up
ContextKit.track("signup_completed", properties: [
    "method": "email"
])

ContextKit.identify("user_123")
ContextKit.setUser(properties: [
    "plan": "free",
    "signup_source": "organic"
])

// User upgrades
ContextKit.setUserSegment("premium")
ContextKit.track("upgrade_completed")
```

## View Your Data

1. Visit [contextkit.dev/dashboard](https://contextkit.dev/dashboard)
2. Select your app
3. View real-time events with context
4. Explore context breakdowns (country, time, device)

## Troubleshooting

### Events Not Appearing?

1. Check your API key is correct
2. Verify you're using the right environment (test vs live)
3. Enable debug mode to see local event tracking
4. Check network connectivity

### Debug Overlay Not Showing?

1. Ensure `debugMode: true` in config
2. Shake device harder (needs significant motion)
3. Only works on physical devices (not simulator)

### Build Errors?

1. Ensure iOS deployment target is 15.0+
2. Clean build folder (Shift+Cmd+K)
3. Update to latest Xcode version

## Next Steps

- Read the [full documentation](https://docs.contextkit.dev)
- Join our [Discord community](https://discord.gg/contextkit)
- Follow [@contextkit](https://twitter.com/contextkit) for updates
- Star us on [GitHub](https://github.com/contextkit/contextkit)

## Support

Need help? We're here for you:

- 📧 Email: support@contextkit.dev
- 💬 Discord: discord.gg/contextkit
- 📚 Docs: docs.contextkit.dev
- 🐛 Issues: github.com/contextkit/contextkit/issues

---

**Happy tracking!** 🎉

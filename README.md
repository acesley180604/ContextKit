# ContextKit

<div align="center">

![ContextKit Logo](https://via.placeholder.com/150?text=ContextKit)

**Context-Aware Event Tracking + AI Diagnostics SDK for iOS**

*Mixpanel tells you what happened. We tell you what's wrong and how to fix it.*

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![SPM](https://img.shields.io/badge/SPM-compatible-green.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/contextkit/contextkit)](https://github.com/contextkit/contextkit/stargazers)

[Quick Start](#quick-start) • [Features](#features) • [Documentation](#documentation) • [Roadmap](#roadmap)

</div>

---

## The Problem

Indie iOS developers face three critical problems with existing analytics tools:

❌ **Event Overload** — Mixpanel/Amplitude dump thousands of events without context. You drown in data but lack actionable insights.

❌ **No Contextual Awareness** — A user opening your app at 11pm in Tokyo has completely different intent than a user in Berlin at 8am. No SDK captures this automatically.

❌ **No Diagnostic Layer** — Current tools tell you WHAT happened, not WHY. You must manually segment data, cross-reference, and guess at root causes.

## The Solution

ContextKit is a 3-layer iOS SDK that transforms raw event tracking into actionable intelligence:

| Layer | Function | Value |
|-------|----------|-------|
| **Phase 1: Context Engine** ✅ | Auto-tag every event with time, geo, device, user segment | Drop-in replacement for Mixpanel with zero config |
| **Phase 2: AI Diagnostics** 🚧 | Analyze patterns across contexts, detect anomalies | "Your signup drops 40% in Germany at night" |
| **Phase 3: Benchmark DB** 📋 | Compare against anonymized data from all SDK users | "Top apps convert 2x with social proof in Asia" |

## Quick Start

### Installation

Add ContextKit to your project via Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/contextkit/contextkit.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/contextkit/contextkit`
3. Add to your app target

### Usage

**Two lines to start:**

```swift
import ContextKit

// Configure once in AppDelegate or @main App
ContextKit.configure(apiKey: "ck_live_xxx")
```

**Track events — context auto-captured:**

```swift
// Basic event - context automatically captured
ContextKit.track("paywall_viewed")

// Event with custom properties
ContextKit.track("purchase_completed", properties: [
    "plan": "annual",
    "price": 49.99,
    "currency": "USD"
])

// Track screen views
ContextKit.trackScreen("onboarding_step_2")

// Identify user
ContextKit.identify("user_123")
ContextKit.setUser(properties: ["plan": "premium"])
```

**That's it!** Every event is automatically enriched with:

## What Gets Auto-Captured

| Context | Data Points | Example Values |
|---------|-------------|----------------|
| **Time** | Hour, day of week, timezone, period | `23:15`, `Monday`, `Asia/Hong_Kong`, `night` |
| **Geo** | Country, region, locale, currency | `JP`, `Asia-Pacific`, `ja_JP`, `JPY` |
| **Device** | Model, OS, screen, battery, network | `iPhone 15 Pro`, `iOS 17.2`, `WiFi`, `87%` |
| **User** | Segment, sessions, days active | `premium`, `47 sessions`, `12 days` |
| **Session** | Duration, screens, entry point | `4.2 min`, `5 screens`, `home_tab` |

**Zero permissions required** — Uses only public iOS APIs. No location tracking, no app tracking transparency prompt.

## Comparison

|  | Mixpanel | Amplitude | Superwall | **ContextKit** |
|---|---|---|---|---|
| Event tracking | ✅ | ✅ | Paywall only | ✅ |
| **Auto-context collection** | ❌ | ❌ | ❌ | ✅ |
| **Time-aware segmentation** | Manual | Manual | ❌ | Automatic |
| **Geo-aware segmentation** | Manual | Manual | ❌ | Automatic |
| **User intent detection** | ❌ | ❌ | ❌ | ✅ |
| **AI diagnostics** | ❌ | ❌ | ❌ | ✅ Phase 2 |
| **Cross-market benchmarks** | ❌ | ❌ | ❌ | ✅ Phase 3 |
| **Actionable recommendations** | ❌ | ❌ | Paywall only | Full app |
| Pricing | $25+/mo | $49+/mo | $0-$1500/mo | **Free tier** |

## Features

### ✅ Available Now (Phase 1)

- **Automatic Context Capture** — Every event tagged with time, geo, device, user, session context
- **Zero Configuration** — No manual setup of segments, cohorts, or tracking plans
- **Zero Permissions** — No location tracking, no ATT prompt, no privacy concerns
- **In-App Debug Overlay** — Shake to view real-time event stream with context (debug mode)
- **Batch Upload** — Efficient networking with automatic retry and offline queueing
- **Swift Package Manager** — Easy integration, zero dependencies
- **Type-Safe API** — Full Swift concurrency support with async/await

### 🚧 Coming Soon (Phase 2)

- **AI Diagnostics Engine** — Automatic anomaly detection across context dimensions
- **Smart Insights** — "Conversion drops 38% in Germany after 9pm"
- **Root Cause Analysis** — AI identifies patterns you'd never find manually
- **Recommendations API** — Get actionable suggestions programmatically

### 📋 Roadmap (Phase 3)

- **Benchmark Database** — Compare your app against anonymized aggregate data
- **Market Intelligence** — "Top apps in Japan show social proof above fold"
- **Conversion Patterns** — Learn from the best performers in your category
- **Competitive Analysis** — Understand what works across different markets

## Dashboard Preview

![Dashboard Screenshot](https://via.placeholder.com/800x450?text=Dashboard+Preview)

View your analytics at [contextkit.dev/dashboard](https://contextkit.dev/dashboard)

## Architecture

```
ContextKit/
├── Core/
│   ├── ContextKit.swift         # Public API
│   ├── EventTracker.swift       # Event queue & batch upload
│   └── ContextKitConfig.swift   # Configuration
├── Context/
│   ├── TimeContext.swift         # Time-of-day awareness
│   ├── GeoContext.swift          # Geographic context
│   ├── DeviceContext.swift       # Device state
│   ├── UserContext.swift         # User properties
│   └── SessionContext.swift      # Session tracking
├── Network/
│   ├── APIClient.swift           # Backend communication
│   └── Retry logic with exponential backoff
└── Dashboard/
    └── ContextDashboard.swift    # In-app debug UI
```

## Documentation

- **[Full Documentation](https://docs.contextkit.dev)** — Complete API reference
- **[Integration Guide](https://docs.contextkit.dev/integration)** — Step-by-step setup
- **[Context Guide](https://docs.contextkit.dev/context)** — Understanding captured context
- **[Best Practices](https://docs.contextkit.dev/best-practices)** — Optimize your tracking
- **[API Reference](https://docs.contextkit.dev/api)** — All methods and types

## Examples

### Track Paywall Events with Context

```swift
// Paywall viewed - auto-captures time, geo, device
ContextKit.track("paywall_viewed")

// If user converts, you'll see exactly when/where they convert best
ContextKit.track("purchase_completed", properties: [
    "plan": "annual",
    "price": 49.99
])
```

Later, your dashboard shows:
- ✅ Users in Japan convert 2.3x better on weekends
- ✅ Germany users drop off 40% after 9pm
- ✅ iPhone 15 Pro users convert 1.8x vs iPhone 13

### Identify High-Value Users

```swift
ContextKit.identify("user_123")
ContextKit.setUserSegment("premium")
ContextKit.setUser(properties: [
    "plan": "annual",
    "mrr": 49.99,
    "signup_source": "product_hunt"
])
```

### Debug in Real-Time

```swift
// Enable debug mode in development
ContextKit.configure(
    apiKey: "ck_test_xxx",
    config: .init(debugMode: true)
)

// Shake device to see live event stream with full context
```

## Pricing

| Tier | Price | Events | Apps | Features |
|------|-------|--------|------|----------|
| **Free** | $0 | 5K/mo | 1 | Context tracking, dashboard, debug overlay |
| **Growth** | $29/mo | 100K/mo | 3 | All free + AI insights (Phase 2), export |
| **Scale** | $99/mo | 1M/mo | Unlimited | All growth + benchmarks, priority support |
| **Enterprise** | Custom | Unlimited | Unlimited | Custom AI models, SLA, dedicated support |

Get your free API key at [contextkit.dev](https://contextkit.dev)

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup

```bash
# Clone the repo
git clone https://github.com/contextkit/contextkit.git
cd contextkit

# Open in Xcode
open Package.swift

# Run tests
swift test
```

## Roadmap

- [x] Phase 1: Context-aware event tracking
- [x] Swift Package with zero dependencies
- [x] In-app debug dashboard
- [x] Cloudflare Workers backend
- [x] Web dashboard
- [ ] Phase 2: AI-powered diagnostics (Q2 2026)
- [ ] Anomaly detection engine
- [ ] Smart recommendations API
- [ ] Phase 3: Cross-app benchmark database (Q3 2026)
- [ ] Android SDK (Q4 2026)

## FAQ

**Q: Do I need to request location permissions?**
A: No! ContextKit uses `Locale.current` which requires zero permissions.

**Q: How does this compare to Mixpanel?**
A: ContextKit is a drop-in replacement with automatic context enrichment. Instead of manually creating segments for each dimension (country, time, device), every event is auto-tagged.

**Q: What about privacy?**
A: We only collect data you explicitly track. No device fingerprinting, no cross-app tracking, fully GDPR/CCPA compliant.

**Q: Can I self-host the backend?**
A: Yes! The backend is open source (Cloudflare Workers + D1). Deploy your own instance.

**Q: What's the catch?**
A: No catch. Free tier is truly free forever. We monetize via paid tiers for scale.

## License

ContextKit is available under the MIT license. See [LICENSE](LICENSE) for details.

## Support

- 📧 Email: [support@contextkit.dev](mailto:support@contextkit.dev)
- 💬 Discord: [discord.gg/contextkit](https://discord.gg/contextkit)
- 🐦 Twitter: [@contextkit](https://twitter.com/contextkit)
- 📚 Docs: [docs.contextkit.dev](https://docs.contextkit.dev)

## Credits

Built by [@acesley](https://github.com/acesley) with ☕️ and 🎵 in Hong Kong.

Inspired by the limitations of existing analytics tools and the needs of indie iOS developers.

---

<div align="center">

**[⭐️ Star us on GitHub](https://github.com/contextkit/contextkit)** if you find ContextKit useful!

Made with ❤️ for indie iOS developers

</div>

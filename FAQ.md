# Frequently Asked Questions

Common questions about ContextKit, answered.

---

## General

### Does ContextKit require any permissions?

**No.** ContextKit requires zero permissions. All context is derived from:
- `Locale.current` - Device language/region settings (no GPS)
- `UIDevice` - Public device info APIs
- `Calendar` - System clock and timezone
- `ProcessInfo` - Device capabilities

No location tracking, no ATT prompt, no tracking consent required beyond standard analytics.

### How accurate is geo detection without GPS?

We use `Locale.current.region` which reflects the user's device language/region settings. This is:
- ✅ **Accurate** for country-level segmentation (what matters for conversion analysis)
- ✅ **Privacy-friendly** - no GPS coordinates collected
- ❌ **Not city-level** - you won't know which city, only country/region

For most analytics use cases (conversion optimization, A/B testing by market), country-level data is sufficient and more privacy-friendly.

### How much does the SDK add to app size?

**~120KB** to your app binary when compiled.

- Zero third-party dependencies
- Pure Swift code
- Optimized for minimal footprint

For comparison:
- Mixpanel SDK: ~2.5MB
- Amplitude SDK: ~1.8MB
- Firebase Analytics: ~3.2MB

---

## Technical

### Does ContextKit work offline?

**Yes.** Events are queued in local storage (`UserDefaults`) when offline.

- Events stored with original timestamp and context
- Uploaded on next app launch with connectivity
- Automatic retry with exponential backoff
- No data loss

### What iOS versions are supported?

- **Minimum:** iOS 15.0
- **Swift:** 5.9+
- **Xcode:** 15.0+

We use modern Swift concurrency (async/await, actors) which requires iOS 15+.

### How fast is context capture?

**< 10ms** per event. Context collection is:
- Synchronous (no network calls)
- Cached where possible
- Optimized for minimal CPU/battery impact

You can track hundreds of events per second without performance degradation.

### Is the SDK thread-safe?

**Yes.** ContextKit uses Swift actors for thread safety:
- Event queue is actor-isolated
- Context managers are actor-isolated
- No race conditions or data corruption
- Safe to call from any thread

### Does it work with SwiftUI and UIKit?

**Yes, both.**

**SwiftUI:**
```swift
@main
struct MyApp: App {
    init() {
        ContextKit.configure(apiKey: "ck_live_xxx")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

**UIKit:**
```swift
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    ContextKit.configure(apiKey: "ck_live_xxx")
    return true
}
```

---

## Integration

### Can I use ContextKit alongside Mixpanel or Amplitude?

**Yes.** ContextKit does not conflict with other analytics SDKs.

Many users run both during a migration period:
1. Install ContextKit
2. Track to both SDKs for 1-2 weeks
3. Verify data matches
4. Remove old SDK

### Can I migrate from Mixpanel?

**Yes.** Most apps migrate in under 30 minutes. See [MIGRATION_FROM_MIXPANEL.md](MIGRATION_FROM_MIXPANEL.md) for step-by-step guide.

The tracking API is intentionally similar:
```swift
// Mixpanel
Mixpanel.mainInstance().track(event: "paywall_viewed")

// ContextKit
ContextKit.track("paywall_viewed")
```

### Do I need to change my event names?

**No.** Use your existing event names.

We recommend `snake_case` for consistency:
- ✅ `paywall_viewed`
- ✅ `purchase_completed`
- ❌ `PaywallViewed`
- ❌ `purchase-completed`

See [BEST_PRACTICES.md](BEST_PRACTICES.md) for naming conventions.

---

## Privacy & Security

### Is ContextKit GDPR/CCPA compliant?

**Yes.** ContextKit is privacy-first:

- No device fingerprinting
- No cross-app tracking
- No personal data without explicit user identification
- Only tracks what you explicitly call `track()` for
- User can opt out via standard iOS privacy settings

For GDPR compliance:
1. Add ContextKit to your privacy policy
2. Mention "analytics and usage data collection"
3. Provide opt-out mechanism if required by your interpretation

### How is my data stored and secured?

**In transit:**
- TLS 1.3 encryption
- Certificate pinning (optional)

**At rest:**
- AES-256 encryption
- Stored on Cloudflare's global edge network
- Automatic replication across regions

**Data retention:**
- Events: 90 days (default)
- Aggregations: 2 years
- User data: Until you delete it

### Do you sell data?

**No.** We never sell your data.

Phase 3 (benchmark database) will use **fully anonymized and aggregated** data across all apps, but individual app data is never shared or sold.

### Can I delete user data?

**Yes.** GDPR right to erasure supported.

Contact support@contextkit.dev with:
- App ID
- User ID to delete
- Verification of ownership

Data deleted within 30 days.

---

## Features

### What's the difference between ContextKit and Mixpanel?

| Feature | Mixpanel | ContextKit |
|---------|----------|------------|
| Event tracking | ✅ | ✅ |
| Custom properties | ✅ | ✅ |
| **Auto context capture** | ❌ Manual segments | ✅ Automatic |
| **Time-aware** | Manual | Automatic |
| **Geo-aware** | Manual | Automatic |
| **Device-aware** | Manual | Automatic |
| **AI diagnostics** | ❌ | ✅ Phase 2 |
| **Permissions required** | Location (optional) | None |
| **Pricing (indie)** | $25+/mo | Free tier |

### When is Phase 2 (AI diagnostics) launching?

**Q2 2026.** Join the waitlist at contextkit.dev.

Phase 2 features:
- Automatic anomaly detection
- Pattern recognition across contexts
- Root cause analysis
- AI-powered recommendations
- Insight notifications

### What about Android?

**iOS first.** Android SDK (Kotlin) is on the roadmap for **Q3 2026**.

Join the waitlist to get notified when Android launches.

### Can I self-host ContextKit?

**Not currently.** The SDK is open source (MIT), but the backend is cloud-hosted only.

**Enterprise self-hosted option** is on the long-term roadmap. If this is critical for you, contact sales@contextkit.dev.

---

## Billing & Pricing

### Is there a free tier?

**Yes.** Free tier includes:
- 5,000 events/month
- 1 app
- Full context tracking
- Web dashboard access
- Debug overlay
- Community support

Perfect for indie developers and small apps.

### What happens if I exceed the free tier?

**Nothing bad.** We'll send you an email notification.

You can:
1. Upgrade to Growth tier ($29/mo for 100K events)
2. Reduce event tracking
3. Wait until next month (events over limit are queued)

We never shut off your tracking without warning.

### Can I change plans anytime?

**Yes.** Upgrade or downgrade anytime. Changes take effect immediately.

Prorated billing for upgrades.

### Do you offer discounts?

**Yes:**
- 20% off annual plans
- 50% off for open source projects (contact us)
- Custom pricing for enterprise (>1M events/mo)
- Student discount (email with .edu address)

---

## Troubleshooting

### Events not appearing in dashboard?

**Wait 30-60 seconds.** Events are batched and uploaded every 30 seconds or 20 events (whichever comes first).

If still not appearing:
1. Check you're using the correct API key
2. Enable debug mode to see local events
3. Check network connectivity
4. Verify backend URL is correct
5. See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

### Debug overlay not showing?

1. Ensure `debugMode: true` in config
2. Shake device harder (requires significant motion)
3. Only works on physical devices (not simulator for shake gesture)
4. Alternative: Use Device menu → Shake in simulator

### Build errors when adding package?

1. Ensure iOS deployment target is 15.0+
2. Clean build folder (Shift+Cmd+K)
3. Update Xcode to 15.0+
4. Delete derived data
5. See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## Open Source

### Is the SDK open source?

**Yes.** The iOS SDK is MIT licensed:
- GitHub: https://github.com/acesley180604/ContextKit
- Full source code available
- Contributions welcome
- Transparent implementation

The backend API and AI engine are proprietary.

### Can I contribute?

**Yes!** We welcome contributions.

See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Code of conduct
- Development setup
- Pull request process
- Issue templates

### How do I report bugs?

GitHub Issues: https://github.com/acesley180604/ContextKit/issues

Include:
- iOS version
- Xcode version
- SDK version
- Steps to reproduce
- Debug overlay screenshot (if applicable)

---

## Support

### How do I get help?

**Free tier:**
- 📚 Documentation: See README, guides, API reference
- 💬 Community Discord: discord.gg/contextkit
- 🐛 GitHub Issues: Report bugs

**Paid tiers:**
- 📧 Email support: support@contextkit.dev
- ⚡ Priority support (Growth+ tiers)
- 📞 Video call support (Enterprise)

### What's your SLA?

**Free tier:** Best effort, no SLA

**Growth tier:** 24-hour response time

**Scale tier:** 12-hour response time

**Enterprise:** Custom SLA (typically 1-4 hours)

### Can I schedule a demo?

**Yes.** Email sales@contextkit.dev to schedule a 30-minute demo.

We'll show you:
- Live dashboard with your data
- Context insights in action
- Phase 2 AI diagnostics preview
- Custom setup for your app

---

## More Questions?

- 📧 Email: support@contextkit.dev
- 💬 Discord: discord.gg/contextkit
- 🐦 Twitter: @contextkit
- 📚 Docs: Full documentation in this repo

**Still have questions?** [Open an issue](https://github.com/acesley180604/ContextKit/issues) and we'll add it to this FAQ!

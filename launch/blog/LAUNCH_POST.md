# Introducing ContextKit: Context-Aware Analytics for iOS Developers

*Published: February 15, 2026*

## TL;DR

I built ContextKit, an open-source analytics SDK for iOS that automatically enriches every event with contextual data (time, geo, device, user, session). It's like Mixpanel with automatic intelligent tagging built in. Zero permissions required, free tier for indie devs.

👉 **Try it:** [contextkit.dev](https://contextkit.dev)
👉 **Star it:** [github.com/contextkit/contextkit](https://github.com/contextkit/contextkit)
👉 **Product Hunt:** [Launch link]

## The Problem I Was Trying to Solve

Six months ago, I was using Mixpanel to track analytics in my iOS app. My revenue in the US was strong 🔥 but in Japan it was terrible 💀.

I had all the event data, but I couldn't figure out *why* there was such a huge difference. Was it:

- Time of day? (timezone differences)
- Cultural preferences?
- Device differences?
- User behavior patterns?
- Something else entirely?

Mixpanel showed me WHAT was happening (low conversion in Japan), but not WHY. To dig deeper, I'd have to:

1. Manually create segments for each dimension (country, time, device)
2. Cross-reference multiple reports
3. Export data to spreadsheets
4. Guess at patterns
5. Validate hypotheses manually

As an indie developer, I didn't have time for this. I needed insights, not more data.

## The Insight: Context is Everything

Here's what I realized: **The same event means completely different things in different contexts.**

A user viewing your paywall at:
- 11pm in Tokyo on a Tuesday
- 8am in Berlin on a Saturday
- 3pm in San Francisco on a Sunday

These are three COMPLETELY different user intents, but analytics tools treat them identically.

No SDK automatically captured this context. You had to manually instrument everything.

## What I Built

ContextKit automatically enriches every event with 5 types of context:

### 1. Time Context
- Hour (0-23)
- Day of week (Monday-Sunday)
- Day period (morning/afternoon/evening/night)
- Timezone
- Is weekend?

### 2. Geographic Context
- Country code
- Region (Asia-Pacific, Europe, Americas, etc.)
- Locale
- Currency code
- Language code

### 3. Device Context
- Model (iPhone 15 Pro, etc.)
- OS version
- Screen size
- Battery level & state
- Network type (WiFi/cellular)
- Low power mode status

### 4. User Context
- User ID (developer-provided)
- Segment (free/premium/trial)
- Session count
- Days since install
- Custom properties

### 5. Session Context
- Session ID
- Duration
- Screen views
- Event count
- Entry screen

**The best part:** This requires **ZERO permissions**. No location tracking, no App Tracking Transparency prompt. Just `Locale.current` and public iOS APIs.

## How It Works

### Installation

Add via Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/contextkit/contextkit.git", from: "1.0.0")
]
```

### Configuration

Two lines of code:

```swift
import ContextKit

ContextKit.configure(apiKey: "ck_live_xxx")
```

### Tracking

Track events like normal:

```swift
ContextKit.track("paywall_viewed")

ContextKit.track("purchase_completed", properties: [
    "plan": "annual",
    "price": 49.99
])
```

That's it. Every event now includes full context automatically.

## What I Discovered

I integrated ContextKit into my own apps first (dogfooding FTW). Here's what I found:

### Insight #1: Time of Day Matters WAY More Than I Thought

**Japan users:** Convert 2.3x better on weekends vs weekdays
**Germany users:** Drop off 40% after 9pm
**US users:** Peak conversion: 2-4pm local time

I would NEVER have discovered this manually segmenting Mixpanel data.

### Insight #2: Device Context Reveals Premium Intent

**iPhone 15 Pro users:** Convert 1.8x vs iPhone 13
**WiFi users:** 3.2x longer sessions than cellular
**Low power mode:** 62% drop in conversion

This helped me optimize for high-intent users.

### Insight #3: Geographic Patterns are Non-Obvious

**Asia-Pacific:** 45% higher conversion with social proof above fold
**Europe:** Privacy messaging increased trust by 23%
**Americas:** "Limited time" messaging converted 31% better

Each region responded to completely different messaging strategies.

## Technical Architecture

### SDK (Swift)

- **Zero dependencies** (critical for adoption)
- **Swift 5.9+, iOS 15+**
- **Fully async/await** with actors for thread safety
- **Automatic retry** with exponential backoff
- **Offline queueing** via UserDefaults
- **Batch uploads** (configurable interval)
- **In-app debug overlay** (shake to view)

Context capture is **synchronous and fast** (< 10ms). No network calls, no async delays.

### Backend (Cloudflare Workers)

- **Edge deployment** for global low latency
- **D1 (SQLite)** for MVP storage
- **Zod validation** for type safety
- **Rate limiting** to prevent abuse
- **CORS** enabled for dashboard

The backend is also open source. You can self-host if you want.

### Dashboard (Next.js 14)

- **App Router** with React Server Components
- **Tremor** for charts
- **Tailwind CSS** with dark theme
- **Real-time event stream**
- **Context breakdowns** (country, time, device)

## The Privacy Story

Privacy is CRITICAL for iOS developers. ContextKit:

✅ **No location permissions required**
✅ **No device fingerprinting**
✅ **No cross-app tracking**
✅ **GDPR/CCPA compliant**
✅ **Fully transparent** (open source)

We use `Locale.current` for country/region, which doesn't require location permissions and doesn't provide precise location data.

All data collection is explicit (you call `.track()`). No silent background tracking.

## Business Model

**Free tier:** 5K events/month, 1 app, full context tracking
**Growth:** $29/mo for 100K events, 3 apps
**Scale:** $99/mo for 1M events, unlimited apps
**Enterprise:** Custom pricing

Free tier is genuinely free forever. I want indie developers to benefit from this without cost barriers.

We monetize from apps that scale (which is fair - they're getting massive value).

## The Roadmap

### Phase 1: Context Engine ✅ (Available Now)

Automatic context capture on every event. This is the foundation.

### Phase 2: AI Diagnostics 🚧 (Coming Q2 2026)

Instead of you digging through data, the AI tells you what's wrong:

*"Conversion drops 38% in Germany after 9pm. Analysis: Users research in evening but don't purchase until morning. Recommendation: Show time-limited offers in evening to create urgency."*

This is where it gets REALLY powerful.

### Phase 3: Benchmark Database 📋 (Coming Q3 2026)

Compare your app against anonymized aggregate data from all ContextKit users:

*"Top-performing apps in Japan show 2x conversion with social proof above fold. Your app shows 0.8x. Recommendation: A/B test social proof placement."*

Learn from the best performers in your category.

## Lessons Learned Building This

### 1. Dogfood Your Own Product

I used ContextKit in my own apps BEFORE launching publicly. This revealed:
- Performance bottlenecks
- Missing features
- UX friction
- Real insights that validated the value prop

If you can't use your own product, fix it before launching.

### 2. Zero Dependencies is a Feature

I initially considered using Alamofire for networking. Decided against it.

Why? Every dependency is friction for adoption. ContextKit uses only URLSession and stdlib.

Result: Developers trust it more and install without hesitation.

### 3. Debug Tooling is Critical

The in-app debug overlay (shake to view events) was an afterthought. It became the #1 feature developers love.

Why? It builds TRUST. You can SEE what's being tracked in real-time.

Lesson: Make your product observable.

### 4. Privacy as a Feature

I marketed "zero permissions required" heavily. Developers care about this.

Privacy isn't just compliance - it's a competitive advantage.

### 5. Launch with a Polished MVP

Phase 1 doesn't have AI features yet, but what it DOES have is polished:
- Complete documentation
- Beautiful dashboard
- Working SDK
- Real insights

Launch when Phase 1 is excellent, not when Phase 3 is half-done.

## Open Source Strategy

ContextKit is MIT licensed. Why open source?

1. **Trust:** Developers can audit the code
2. **Contributions:** Community can improve it
3. **Self-hosting:** Enterprise can deploy their own
4. **Marketing:** GitHub stars = social proof

BUT: The value is in the SaaS (hosted backend, AI insights, benchmark DB). Open source the SDK, monetize the service.

## What's Next

**Short term:**
- Integrate feedback from early adopters
- Performance optimizations
- More context dimensions (battery state, disk space, etc.)
- Android SDK (Q4 2026)

**Medium term:**
- Phase 2 AI diagnostics (private beta starting Q2)
- Integration with popular tools (RevenueCat, Superwall)
- VS Code extension for exploring data

**Long term:**
- Phase 3 benchmark database
- ML models for predictive analytics
- Multi-platform (React Native, Flutter)

## Try It

**Get started:** [contextkit.dev](https://contextkit.dev)

**GitHub:** [github.com/contextkit/contextkit](https://github.com/contextkit/contextkit)

**Documentation:** [docs.contextkit.dev](https://docs.contextkit.dev)

**Product Hunt:** [Launch link] (would love your upvote!)

## Questions?

I'm [@acesley](https://twitter.com/acesley) on Twitter. DMs are open!

Or email: acesley@contextkit.dev

Would love to hear:
- What context dimensions am I missing?
- What insights would be most valuable?
- What analytics pain points do you have?

## Thank You

To everyone who:
- Gave early feedback
- Tested the beta
- Upvoted on Product Hunt
- Starred on GitHub
- Shared with other devs

This wouldn't exist without you. Thank you! 🙏

---

**P.S.** If you're an indie iOS developer struggling with analytics, I built ContextKit for you. It's free to start, open source, and might just help you discover insights that transform your business (like it did for me).

Give it a try: [contextkit.dev](https://contextkit.dev)

---

*Acesley is an indie iOS developer from Hong Kong building tools for other indie developers. Follow his journey on [Twitter](https://twitter.com/acesley).*

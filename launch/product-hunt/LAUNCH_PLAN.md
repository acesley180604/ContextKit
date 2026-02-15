# ContextKit Product Hunt Launch Plan

## Pre-Launch (2 Weeks Before)

### Week -2

- [x] Create Product Hunt "upcoming" page
- [ ] Share on X/Twitter with "Follow for launch" CTA
- [ ] Post in iOS dev communities (r/iOSProgramming, r/SwiftUI)
- [ ] Email previous supporters/followers
- [ ] **Goal: 200+ followers on upcoming page**

### Week -1

- [ ] Finalize all marketing materials
- [ ] Test SDK in 3+ real apps
- [ ] Record demo video (60-90 seconds)
- [ ] Create launch day graphics
- [ ] Line up 20+ supporters to upvote at 00:01 PST
- [ ] Prepare responses to common questions

## Launch Day Checklist

### 00:01 PST - Launch

- [ ] Submit to Product Hunt
- [ ] Post maker comment (see below)
- [ ] Share launch link with supporter list
- [ ] Pin tweet with launch announcement

### Morning (06:00-12:00 PST)

- [ ] Post on Hacker News: "Show HN: ContextKit - context-aware analytics for iOS"
- [ ] Post on Reddit:
  - r/iOSProgramming
  - r/SwiftUI
  - r/IndieHackers
- [ ] Share in Discord communities:
  - SwiftUI developers
  - iOS developers
  - Indie hackers
- [ ] Post on Indie Hackers with build story
- [ ] Email newsletter subscribers

### Afternoon (12:00-18:00 PST)

- [ ] Monitor and respond to ALL comments within 5 minutes
- [ ] Share user testimonials as they come in
- [ ] Post progress updates: "We hit #1 on PH!", "100 stars on GitHub!"
- [ ] Engage with other launches (give to get)

### Evening (18:00-24:00 PST)

- [ ] Final push on social media
- [ ] Thank supporters publicly
- [ ] Share final ranking
- [ ] Plan follow-up content

## Maker Comment Template

```
Hey Product Hunt! 👋

I'm Acesley, an indie iOS dev from Hong Kong. I built ContextKit because I was drowning in Mixpanel events and couldn't figure out WHY my app converted great in the US but terribly in Japan.

🎯 The Problem
Mixpanel dumps thousands of events without context. You know WHAT happened, but not WHY. Was it the time of day? The country? The device? You have to manually segment everything and guess.

💡 The Solution
ContextKit automatically enriches EVERY event with context:
• Time: hour, day of week, period (morning/afternoon/evening/night)
• Geo: country, region, locale, currency (NO permissions needed!)
• Device: model, OS, battery, network
• User: segment, session count, days active
• Session: duration, screens viewed, entry point

🚀 Two lines to start:
```swift
import ContextKit
ContextKit.configure(apiKey: "ck_live_xxx")
ContextKit.track("paywall_viewed")
```

That's it. Every event is now tagged with full context.

🔮 What's Next
Phase 2 (coming Q2): AI diagnostics that tell you "Conversion drops 38% in Germany after 9pm" and WHY.
Phase 3 (Q3): Benchmark DB comparing your app against top performers in your category.

📊 Already tracking 10K+ events/day in my own apps and found insights I'd NEVER have discovered manually.

🎁 Free tier: 5K events/month, perfect for indie devs

Would love your feedback! Try it, break it, tell me what's missing.

🔗 Links:
• GitHub: github.com/contextkit/contextkit
• Dashboard: contextkit.dev/dashboard
• Docs: docs.contextkit.dev

Questions? Fire away! 🚀
```

## Twitter Thread Template

```
🧵 I built the analytics SDK I wish existed

Mixpanel tells you WHAT happened.
ContextKit tells you WHY and HOW to fix it.

Here's the story 👇

1/ I'm an indie iOS dev. I was using Mixpanel for my app.

Revenue in the US: 🔥
Revenue in Japan: 💀

Why? I had NO idea. I drowned in event data but couldn't find the signal.

2/ Mixpanel has all the events but ZERO context.

Was it the time of day? The device? Cultural differences? I'd have to manually segment everything and guess.

There had to be a better way.

3/ So I built ContextKit.

It automatically tags EVERY event with:
• Time context (hour, day, period)
• Geo context (country, region, locale)
• Device context (model, OS, battery)
• User context (segment, sessions)
• Session context (duration, screens)

4/ NO permissions needed.

Uses only public iOS APIs. No location tracking, no ATT prompt.

Just Locale.current and UIDevice APIs.

Drop-in replacement for Mixpanel with ZERO config.

5/ Two lines to start:

```swift
import ContextKit
ContextKit.configure(apiKey: "ck_live_xxx")
```

That's it. Now when you track events:

```swift
ContextKit.track("paywall_viewed")
```

You get full context automatically.

6/ Here's what I discovered in MY app:

✅ Japan users convert 2.3x better on WEEKENDS
✅ Germany users drop 40% after 9pm
✅ iPhone 15 Pro users convert 1.8x vs iPhone 13

I'd NEVER have found this manually.

7/ Phase 2 (coming soon): AI diagnostics

Instead of you digging through data, the AI tells you:
"Your signup flow drops 38% in Germany after 9pm. Recommendation: Add social proof above fold for EU markets."

8/ Phase 3: Benchmark database

Compare your app against anonymized data from ALL ContextKit users:
"Top apps in Japan show 2x conversion with social proof above fold"

Learn from the best performers.

9/ It's FREE to start.

5K events/month, 1 app, full context tracking.

Perfect for indie devs.

🔗 Try it: contextkit.dev
📦 Star it: github.com/contextkit/contextkit
🚀 Just launched on @ProductHunt: [link]

10/ Would love your feedback!

What context dimensions am I missing?
What insights would be most valuable?

Let me know! 👇
```

## Reddit Post Template (r/iOSProgramming)

**Title:** I built a context-aware analytics SDK for iOS (open source)

**Body:**

Hey everyone! I just launched ContextKit, an analytics SDK that automatically enriches every event with contextual data.

**The Problem I Had:**

I was using Mixpanel for my app and drowning in event data but couldn't figure out WHY my conversion varied so much across different markets and times. Manually segmenting by every dimension (country, time, device) was tedious and I kept missing insights.

**What I Built:**

ContextKit auto-captures 5 types of context on EVERY event:

1. Time context (hour, day of week, period)
2. Geo context (country, region, locale) - NO permissions needed
3. Device context (model, OS, battery, network)
4. User context (segment, sessions, days active)
5. Session context (duration, screens viewed)

**How It Works:**

```swift
import ContextKit

ContextKit.configure(apiKey: "ck_live_xxx")
ContextKit.track("paywall_viewed")
```

That's it. Every event now has full context.

**What I Discovered:**

Using it in my own apps, I found:
- Japan users convert 2.3x better on weekends
- Germany users drop off 40% after 9pm
- iPhone 15 Pro users convert 1.8x vs older models

I'd never have found these patterns manually.

**Tech Stack:**

- Swift 5.9+, iOS 15+
- Zero dependencies (SPM only)
- Async/await throughout
- Cloudflare Workers backend
- Zero permissions required

**Features:**

- In-app debug overlay (shake to view)
- Automatic retry with exponential backoff
- Offline queueing
- Batch uploads

**Coming Soon:**

Phase 2: AI diagnostics that detect anomalies and provide recommendations
Phase 3: Cross-app benchmark database

**Links:**

- GitHub: https://github.com/contextkit/contextkit
- Dashboard: https://contextkit.dev
- Product Hunt: [link]

Would love your feedback! What context dimensions would be most valuable for your apps?

## Hacker News Template

**Title:** Show HN: ContextKit – Context-aware analytics SDK for iOS

**Body:**

Hey HN! I'm Acesley, an indie iOS dev. I built ContextKit because existing analytics tools (Mixpanel, Amplitude) dump thousands of events but lack contextual awareness.

The core insight: A user opening your app at 11pm in Tokyo has completely different intent than a user in Berlin at 8am. But no SDK captures this automatically.

ContextKit auto-enriches every event with time, geo, device, user, and session context. The key is it requires ZERO permissions (uses Locale.current and public APIs only).

Two-line integration:

```swift
import ContextKit
ContextKit.configure(apiKey: "ck_live_xxx")
```

Using it in my own apps, I discovered patterns I'd never have found manually (e.g., Japan users convert 2.3x better on weekends, Germany drops 40% after 9pm).

Tech: Swift Package, zero deps, Cloudflare Workers backend, MIT licensed.

Phase 2 (coming): AI diagnostics for anomaly detection
Phase 3: Cross-app benchmark database

Links:
- GitHub: https://github.com/contextkit/contextkit
- Live demo: https://contextkit.dev
- Docs: https://docs.contextkit.dev

Happy to answer questions about the architecture, privacy approach, or how we achieve <10ms context capture!

## Success Metrics

### Launch Day Goals

- [ ] 200+ upvotes on Product Hunt
- [ ] Top 5 product of the day
- [ ] 100+ GitHub stars
- [ ] 50+ SDK installations
- [ ] 10+ dashboard signups
- [ ] 1000+ website visits

### Week 1 Goals

- [ ] 500+ GitHub stars
- [ ] 100+ SDK installations
- [ ] 20+ active apps tracking events
- [ ] 10K+ events processed
- [ ] Featured in iOS dev newsletter

### Month 1 Goals

- [ ] 1000+ GitHub stars
- [ ] 50+ active apps
- [ ] 100K+ events processed
- [ ] 100+ waitlist for Phase 2 AI features
- [ ] First revenue from paid tier

## Post-Launch Content Calendar

### Week 1
- Day 1: Launch recap blog post
- Day 3: "How I got 200+ upvotes on PH" post
- Day 5: First user case study
- Day 7: Technical deep-dive on architecture

### Week 2
- "5 insights I never would have found without context"
- "How to optimize your paywall using context data"
- Video tutorial series

### Week 3
- "ContextKit vs Mixpanel: A detailed comparison"
- SEO blog: "Best analytics tools for indie iOS developers"
- Guest post on iOS dev blogs

### Week 4
- "We processed 100K events - here's what we learned"
- Anonymized insights from SDK data (privacy-safe)
- Roadmap for Phase 2

## Supporter Outreach List

### iOS Dev Influencers to DM
- @johnsundell
- @twostraws
- @objcio
- @swiftbysundell
- @donny_wals

### Communities to Post In
- iOS Developers Discord
- SwiftUI Slack
- Indie Hackers
- Hacker News
- Reddit r/iOSProgramming
- RevenueCat community

### Newsletter Outreach
- iOS Dev Weekly
- Swift Weekly Brief
- iOS Goodies
- Indie iOS Focus

## FAQ Responses

**Q: How is this different from Mixpanel?**
A: Mixpanel requires manual segmentation for each dimension. ContextKit auto-enriches every event with time, geo, device context. It's like Mixpanel with automatic intelligent tagging built in.

**Q: Do you track location?**
A: No! We use Locale.current which requires zero permissions. You get country/region without GPS or location tracking.

**Q: Is the backend open source too?**
A: Yes! Cloudflare Workers + D1. You can self-host if you want.

**Q: How do you make money?**
A: Free tier for indie devs (5K events/mo). Paid tiers for scale ($29/mo for 100K events). Enterprise for custom needs.

**Q: When is Phase 2 AI launching?**
A: Q2 2026. Join the waitlist and you'll get early access.

**Q: Can I use this in production?**
A: Yes! Already processing 10K+ events/day in production apps.

---

**LET'S GO! 🚀**

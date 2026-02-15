# Troubleshooting Guide

Common issues and solutions for ContextKit.

---

## Table of Contents

- [Installation Issues](#installation-issues)
- [Configuration Issues](#configuration-issues)
- [Tracking Issues](#tracking-issues)
- [Dashboard Issues](#dashboard-issues)
- [Performance Issues](#performance-issues)
- [Build Issues](#build-issues)

---

## Installation Issues

### Package Resolution Fails

**Problem:** Xcode can't resolve ContextKit package.

**Solutions:**

1. **Verify URL is correct:**
   ```
   https://github.com/acesley180604/ContextKit
   ```

2. **Check internet connection**

3. **Clear package cache:**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   rm -rf ~/Library/Caches/org.swift.swiftpm
   ```

4. **Update package dependencies:**
   - File → Packages → Update to Latest Package Versions

5. **Restart Xcode**

---

### Wrong Version Installed

**Problem:** Package installs old version or wrong tag.

**Solutions:**

1. **Check dependency rule:**
   - Should be "Up to Next Major Version"
   - Minimum version: `1.0.0`

2. **Force update:**
   - File → Packages → Update to Latest Package Versions

3. **Remove and re-add:**
   - File → Packages → Remove Package
   - File → Add Package Dependencies
   - Re-add ContextKit

---

## Configuration Issues

### "ContextKit not configured" Warning

**Problem:**
```
⚠️ ContextKit not configured. Call ContextKit.configure() first.
```

**Solutions:**

1. **Call `configure()` before `track()`:**

   ✅ **Correct:**
   ```swift
   @main
   struct MyApp: App {
       init() {
           ContextKit.configure(apiKey: "ck_live_xxx")  // First
       }

       var body: some Scene {
           WindowGroup {
               ContentView()  // Then views that track events
           }
       }
   }
   ```

   ❌ **Wrong:**
   ```swift
   struct ContentView: View {
       init() {
           ContextKit.track("view_loaded")  // Before configure!
       }
   }
   ```

2. **Verify configuration is called:**
   ```swift
   if ContextKit.isConfigured {
       print("✅ Configured")
   } else {
       print("❌ Not configured")
   }
   ```

---

### Invalid API Key Error

**Problem:** Backend returns 401 Unauthorized.

**Solutions:**

1. **Verify API key format:**
   - Production: `ck_live_...`
   - Test: `ck_test_...`
   - Should be 30+ characters

2. **Check for typos:**
   - No extra spaces
   - No newlines
   - Copy-paste directly from dashboard

3. **Verify environment:**
   ```swift
   #if DEBUG
   let apiKey = "ck_test_development_12345"
   #else
   let apiKey = "ck_live_production_key"
   #endif

   ContextKit.configure(apiKey: apiKey)
   ```

4. **Get new API key:**
   - Visit https://contextkit.dev
   - Create new app
   - Copy fresh API key

---

## Tracking Issues

### Events Not Appearing in Dashboard

**Problem:** Track events but don't see them in dashboard.

**Diagnosis Checklist:**

1. ✅ **Wait 30-60 seconds** (events batch every 30s)

2. ✅ **Check debug overlay:**
   ```swift
   // Enable debug mode
   let config = ContextKitConfig(
       apiKey: "ck_live_xxx",
       debugMode: true
   )
   ContextKit.configure(apiKey: "ck_live_xxx", config: config)
   ```
   - Shake device to see events
   - Verify events appear in overlay

3. ✅ **Check network:**
   - Device has internet
   - No corporate firewall blocking API
   - Can reach https://api.contextkit.dev

4. ✅ **Verify backend URL:**
   ```swift
   if let config = ContextKit.getConfig() {
       print("Backend URL: \(config.baseURL)")
   }
   ```

5. ✅ **Check Xcode console:**
   - Look for ContextKit errors
   - Check for network errors

**Solutions:**

1. **Force upload:**
   ```swift
   ContextKit.flush()
   ```

2. **Enable verbose logging:**
   ```swift
   // Add to your config
   let config = ContextKitConfig(
       apiKey: "ck_live_xxx",
       debugMode: true
   )
   ```

3. **Verify backend is running:**
   ```bash
   curl https://api.contextkit.dev/v1/health
   # Should return: {"status":"ok","timestamp":...}
   ```

4. **Check API key permissions:**
   - Verify key hasn't been revoked
   - Check dashboard for API key status

---

### Context Not Being Captured

**Problem:** Events tracked but context is empty or partial.

**Solutions:**

1. **Verify context is enabled:**
   ```swift
   let config = ContextKitConfig(
       apiKey: "ck_live_xxx",
       enableGeo: true,      // ✅
       enableDevice: true,   // ✅
       enableTime: true      // ✅
   )
   ```

2. **Check permissions (shouldn't need any):**
   - ContextKit requires ZERO permissions
   - Uses only public APIs

3. **Verify iOS version:**
   - Minimum: iOS 15.0
   - Some context may be unavailable on older iOS versions

4. **Check simulator vs device:**
   - Some device info unavailable on simulator
   - Battery level always -1 on simulator
   - Network type may be inaccurate

---

### Debug Overlay Not Showing

**Problem:** Shake device but overlay doesn't appear.

**Solutions:**

1. **Enable debug mode:**
   ```swift
   let config = ContextKitConfig(
       apiKey: "ck_live_xxx",
       debugMode: true  // ✅ Must be true
   )
   ContextKit.configure(apiKey: "ck_live_xxx", config: config)
   ```

2. **Shake harder:**
   - Requires significant motion
   - Try shaking more vigorously

3. **Use menu in simulator:**
   - Device → Shake (or Ctrl+Cmd+Z)
   - Physical shake doesn't work in simulator

4. **Check if running on device:**
   - Shake gesture only works on physical devices
   - Use menu in simulator

5. **Verify SwiftUI integration:**
   ```swift
   // Add to your root view:
   .contextKitDebug()  // Extension from ContextKit
   ```

---

## Dashboard Issues

### Dashboard Shows No Data

**Problem:** Dashboard loads but no events visible.

**Solutions:**

1. **Check time range:**
   - Default shows last 7 days
   - Expand to 30 days if events are older

2. **Verify correct app:**
   - Select correct app from dropdown
   - Check app ID matches

3. **Wait for processing:**
   - Events may take 30-60s to appear
   - Refresh page after waiting

4. **Check backend database:**
   ```bash
   # If self-hosting
   wrangler d1 execute contextkit-prod --command="SELECT COUNT(*) FROM events;"
   ```

---

### Charts Not Loading

**Problem:** Dashboard loads but charts are empty.

**Solutions:**

1. **Minimum event threshold:**
   - Some charts require minimum 10 events
   - Track more events

2. **Clear browser cache:**
   - Hard refresh: Cmd+Shift+R (Mac) / Ctrl+Shift+R (Windows)

3. **Check console errors:**
   - Open browser DevTools (F12)
   - Look for JavaScript errors

4. **Try different browser:**
   - Test in Chrome/Safari/Firefox

---

## Performance Issues

### App Feels Slow After Adding ContextKit

**Problem:** App performance degraded.

**Diagnosis:**

1. **Profile with Instruments:**
   - Look for ContextKit calls on main thread
   - Check Time Profiler

2. **Check batch size:**
   ```swift
   let config = ContextKitConfig(
       apiKey: "ck_live_xxx",
       maxBatchSize: 20,        // Default
       uploadInterval: 30.0     // Default
   )
   ```

**Solutions:**

1. **Increase batch interval:**
   ```swift
   let config = ContextKitConfig(
       apiKey: "ck_live_xxx",
       uploadInterval: 60.0  // Upload every 60s instead of 30s
   )
   ```

2. **Reduce tracking frequency:**
   ```swift
   // ❌ Bad: Track in tight loop
   for item in items {
       ContextKit.track("item_viewed", properties: ["id": item.id])
   }

   // ✅ Good: Track summary
   ContextKit.track("items_viewed", properties: ["count": items.count])
   ```

3. **Avoid tracking on main thread:**
   ```swift
   Task.detached {
       ContextKit.track("background_task")
   }
   ```

---

### High Battery Usage

**Problem:** ContextKit causing excessive battery drain.

**Solutions:**

1. **Reduce upload frequency:**
   ```swift
   let config = ContextKitConfig(
       apiKey: "ck_live_xxx",
       uploadInterval: 120.0  // Every 2 minutes
   )
   ```

2. **Disable context you don't need:**
   ```swift
   let config = ContextKitConfig(
       apiKey: "ck_live_xxx",
       enableDevice: false  // Disable if not needed
   )
   ```

3. **Track fewer events:**
   - Review what you're tracking
   - Remove unnecessary events

---

## Build Issues

### "Module 'ContextKit' not found"

**Problem:** Import fails with module not found.

**Solutions:**

1. **Clean build:**
   ```
   Product → Clean Build Folder (Shift+Cmd+K)
   ```

2. **Delete derived data:**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

3. **Verify package is added to target:**
   - Project Settings → Target → General
   - Check "Frameworks, Libraries, and Embedded Content"
   - ContextKit should be listed

4. **Update package:**
   - File → Packages → Update to Latest Package Versions

5. **Restart Xcode**

---

### Build Errors with Swift Version

**Problem:**
```
error: compiling for iOS 14.0, but module 'ContextKit' has a minimum deployment target of iOS 15.0
```

**Solutions:**

1. **Update deployment target:**
   - Project Settings → General → Deployment Target
   - Set to iOS 15.0 or higher

2. **Verify Xcode version:**
   - Xcode 15.0+ required
   - Update Xcode if needed

3. **Check Swift version:**
   - Xcode → About Xcode
   - Should be Swift 5.9+

---

### Linker Errors

**Problem:**
```
Undefined symbol: _$s10ContextKit0aB0C9configure6apiKeyySS_tFZ
```

**Solutions:**

1. **Clean and rebuild:**
   ```
   Product → Clean Build Folder
   Product → Build
   ```

2. **Check target membership:**
   - Select Package.swift in navigator
   - File Inspector → Target Membership
   - Ensure correct target selected

3. **Remove and re-add package:**
   - File → Packages → Remove Package
   - File → Add Package Dependencies
   - Re-add ContextKit

---

## Network Issues

### SSL/TLS Errors

**Problem:**
```
Error: SSL certificate verification failed
```

**Solutions:**

1. **Update iOS:**
   - Ensure iOS 15.0+
   - Update to latest iOS version

2. **Check device date/time:**
   - Settings → General → Date & Time
   - Enable "Set Automatically"

3. **Verify backend URL:**
   - Should start with `https://`
   - Certificate should be valid

---

### Firewall Blocking Requests

**Problem:** Corporate firewall blocking API.

**Solutions:**

1. **Whitelist API domain:**
   - Add `api.contextkit.dev` to firewall whitelist

2. **Check with network admin:**
   - May need to allow Cloudflare Workers domains

3. **Test on different network:**
   - Try on cellular data vs WiFi
   - Confirms if firewall is issue

---

## Debug Mode Issues

### Too Many Debug Logs

**Problem:** Console flooded with ContextKit logs.

**Solutions:**

1. **Disable debug mode in production:**
   ```swift
   #if DEBUG
   let debugMode = true
   #else
   let debugMode = false
   #endif

   let config = ContextKitConfig(
       apiKey: "ck_live_xxx",
       debugMode: debugMode
   )
   ```

2. **Filter Xcode console:**
   - Use filter field in console
   - Filter out "ContextKit"

---

## Still Having Issues?

If none of these solutions work:

1. **Enable debug mode:**
   ```swift
   let config = ContextKitConfig(
       apiKey: "ck_live_xxx",
       debugMode: true
   )
   ```

2. **Collect debug info:**
   - Shake device → Debug overlay
   - Tap "Copy Debug Info"

3. **Open GitHub issue:**
   - https://github.com/acesley180604/ContextKit/issues
   - Include:
     - iOS version
     - Xcode version
     - ContextKit version
     - Debug info (from step 2)
     - Steps to reproduce

4. **Contact support:**
   - 📧 support@contextkit.dev
   - 💬 Discord: discord.gg/contextkit

---

**We're here to help!** 🚀

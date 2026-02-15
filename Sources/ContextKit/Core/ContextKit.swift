import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// ContextKit - Context-aware event tracking SDK for iOS
///
/// # Overview
/// ContextKit automatically enriches every event with contextual data:
/// - Time context (hour, day of week, timezone, period)
/// - Geo context (country, region, locale, currency)
/// - Device context (model, OS, screen, battery, network)
/// - User context (segment, session count, days since install)
/// - Session context (duration, screens viewed, entry point)
///
/// # Quick Start
/// ```swift
/// // Configure once in AppDelegate or @main App
/// ContextKit.configure(apiKey: "ck_live_xxx")
///
/// // Track events - context auto-captured
/// ContextKit.track("paywall_viewed")
/// ContextKit.track("purchase_completed", properties: ["plan": "annual"])
///
/// // Track screen views
/// ContextKit.trackScreen("onboarding_step_2")
///
/// // Identify user
/// ContextKit.identify("user_123")
/// ContextKit.setUser(properties: ["plan": "premium"])
/// ```
///
/// # No Permissions Required
/// ContextKit collects rich context data using only public APIs.
/// No location, tracking, or special permissions needed.
public enum ContextKit {
    private static var instance: ContextKitInstance?
    private static let lock = NSLock()

    /// Configure ContextKit with API key
    /// - Parameters:
    ///   - apiKey: Your ContextKit API key (format: ck_live_xxx or ck_test_xxx)
    ///   - config: Optional configuration (defaults to .default)
    public static func configure(apiKey: String, config: ContextKitConfig? = nil) {
        lock.lock()
        defer { lock.unlock() }

        var finalConfig = config ?? .default
        finalConfig = ContextKitConfig(
            apiKey: apiKey,
            baseURL: finalConfig.baseURL,
            uploadInterval: finalConfig.uploadInterval,
            maxBatchSize: finalConfig.maxBatchSize,
            debugMode: finalConfig.debugMode,
            enableGeo: finalConfig.enableGeo,
            enableDevice: finalConfig.enableDevice,
            enableTime: finalConfig.enableTime,
            enableAutoSession: finalConfig.enableAutoSession
        )

        instance = ContextKitInstance(config: finalConfig)

        print("✅ ContextKit configured successfully")
        print("   API Key: \(apiKey.prefix(15))...")
        print("   Debug Mode: \(finalConfig.debugMode)")
        print("   Version: \(ContextKitSDK.version)")
    }

    /// Track an event with optional properties
    /// - Parameters:
    ///   - eventName: Name of the event (e.g., "paywall_viewed")
    ///   - properties: Custom properties to attach to event
    public static func track(_ eventName: String, properties: [String: Any] = [:]) {
        guard let instance = instance else {
            print("⚠️ ContextKit not configured. Call ContextKit.configure() first.")
            return
        }

        Task {
            await instance.track(name: eventName, properties: properties)
        }
    }

    /// Track a screen view
    /// - Parameter screenName: Name of the screen (e.g., "onboarding_step_2")
    public static func trackScreen(_ screenName: String) {
        guard let instance = instance else {
            print("⚠️ ContextKit not configured. Call ContextKit.configure() first.")
            return
        }

        Task {
            await instance.trackScreen(name: screenName)
        }
    }

    /// Identify the current user
    /// - Parameter userId: Unique user identifier
    public static func identify(_ userId: String) {
        guard let instance = instance else {
            print("⚠️ ContextKit not configured. Call ContextKit.configure() first.")
            return
        }

        Task {
            await instance.identify(userId: userId)
        }
    }

    /// Set user properties
    /// - Parameter properties: User properties (e.g., ["plan": "premium", "signup_source": "organic"])
    public static func setUser(properties: [String: Any]) {
        guard let instance = instance else {
            print("⚠️ ContextKit not configured. Call ContextKit.configure() first.")
            return
        }

        Task {
            await instance.setUserProperties(properties)
        }
    }

    /// Set user segment
    /// - Parameter segment: User segment (e.g., "free", "paid", "trial")
    public static func setUserSegment(_ segment: String) {
        guard let instance = instance else {
            print("⚠️ ContextKit not configured. Call ContextKit.configure() first.")
            return
        }

        Task {
            await instance.setUserSegment(segment)
        }
    }

    /// Force upload all queued events
    public static func flush() {
        guard let instance = instance else {
            return
        }

        Task {
            await instance.flush()
        }
    }

    /// Get AI insights for a specific screen or event (Phase 2)
    /// - Parameter target: Screen name or event name
    /// - Returns: Array of insights
    public static func getInsights(for target: String) async -> [Insight] {
        guard let instance = instance else {
            print("⚠️ ContextKit not configured. Call ContextKit.configure() first.")
            return []
        }

        return await instance.getInsights(for: target)
    }

    /// Get AI recommendations (Phase 2)
    /// - Parameters:
    ///   - screen: Screen name
    ///   - market: Market/country code
    /// - Returns: Array of recommendations
    public static func getRecommendations(for screen: String, market: String? = nil) async -> [Recommendation] {
        guard let instance = instance else {
            print("⚠️ ContextKit not configured. Call ContextKit.configure() first.")
            return []
        }

        return await instance.getRecommendations(for: screen, market: market)
    }

    /// Show debug overlay (shake to open in debug mode)
    /// - Returns: SwiftUI view for debug overlay
    #if canImport(SwiftUI)
    @available(iOS 15.0, *)
    public static func debugOverlay() -> some View {
        guard let instance = instance else {
            return AnyView(EmptyView())
        }

        return AnyView(ContextDashboard(instance: instance))
    }
    #endif

    /// Get current configuration
    public static func getConfig() -> ContextKitConfig? {
        return instance?.config
    }

    /// Check if ContextKit is configured
    public static var isConfigured: Bool {
        return instance != nil
    }
}

// MARK: - Internal Instance

/// Internal singleton instance
actor ContextKitInstance {
    let config: ContextKitConfig
    private let userManager: UserContextManager
    private let sessionManager: SessionManager
    private let apiClient: APIClient
    private let eventTracker: EventTracker

    init(config: ContextKitConfig) {
        self.config = config
        self.userManager = UserContextManager()
        self.sessionManager = SessionManager()
        self.apiClient = APIClient(config: config)
        self.eventTracker = EventTracker(
            config: config,
            userManager: userManager,
            sessionManager: sessionManager,
            apiClient: apiClient
        )

        // Start upload timer
        Task {
            await eventTracker.startUploadTimer()
        }

        // Start initial session if auto-session enabled
        if config.enableAutoSession {
            Task {
                await sessionManager.startSession()
                await userManager.incrementSessionCount()
            }
        }
    }

    func track(name: String, properties: [String: Any]) async {
        await eventTracker.track(name: name, properties: properties)
    }

    func trackScreen(name: String) async {
        await eventTracker.trackScreen(name: name)
    }

    func identify(userId: String) async {
        await userManager.setUserId(userId)
    }

    func setUserProperties(_ properties: [String: Any]) async {
        await userManager.setProperties(properties)
    }

    func setUserSegment(_ segment: String) async {
        await userManager.setSegment(segment)
    }

    func flush() async {
        await eventTracker.flush()
    }

    func getInsights(for target: String) async -> [Insight] {
        // Phase 2: Call API to get insights
        // For now, return empty array
        return []
    }

    func getRecommendations(for screen: String, market: String?) async -> [Recommendation] {
        // Phase 2: Call API to get recommendations
        // For now, return empty array
        return []
    }

    func getEventQueue() async -> [ContextEvent] {
        return await eventTracker.getAllEvents()
    }

    func getCurrentContext() async -> ContextSnapshot {
        return await ContextSnapshot.capture(
            userManager: userManager,
            sessionManager: sessionManager,
            config: config
        )
    }
}

#if canImport(SwiftUI)
import SwiftUI

extension View {
    /// Add ContextKit debug overlay (shake to open)
    @available(iOS 15.0, *)
    public func contextKitDebug() -> some View {
        self.modifier(ContextKitDebugModifier())
    }
}

@available(iOS 15.0, *)
struct ContextKitDebugModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content
            if ContextKit.getConfig()?.debugMode == true {
                ContextKit.debugOverlay()
            }
        }
    }
}

// Placeholder for AnyView
struct AnyView<Content: View>: View {
    let content: Content

    init(_ content: Content) {
        self.content = content
    }

    var body: some View {
        content
    }
}
#endif

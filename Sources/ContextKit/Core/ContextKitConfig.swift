import Foundation

/// Configuration options for ContextKit SDK
public struct ContextKitConfig {
    /// API key for authentication (format: ck_live_xxx or ck_test_xxx)
    public let apiKey: String

    /// Base URL for the ContextKit API
    public let baseURL: String

    /// Interval between batch uploads (in seconds)
    public let uploadInterval: TimeInterval

    /// Maximum number of events to batch before forcing an upload
    public let maxBatchSize: Int

    /// Enable debug mode (shows in-app debug overlay)
    public let debugMode: Bool

    /// Enable geo context collection
    public let enableGeo: Bool

    /// Enable device context collection
    public let enableDevice: Bool

    /// Enable time context collection
    public let enableTime: Bool

    /// Enable automatic session tracking
    public let enableAutoSession: Bool

    /// Default configuration for production use
    public static var `default`: ContextKitConfig {
        return ContextKitConfig(
            apiKey: "",
            baseURL: "https://api.contextkit.dev/v1",
            uploadInterval: 30.0,
            maxBatchSize: 20,
            debugMode: false,
            enableGeo: true,
            enableDevice: true,
            enableTime: true,
            enableAutoSession: true
        )
    }

    /// Create a custom configuration
    /// - Parameters:
    ///   - apiKey: Your ContextKit API key
    ///   - baseURL: API base URL (default: https://api.contextkit.dev/v1)
    ///   - uploadInterval: Seconds between batch uploads (default: 30)
    ///   - maxBatchSize: Max events before forcing upload (default: 20)
    ///   - debugMode: Enable debug overlay (default: false)
    ///   - enableGeo: Collect geo context (default: true)
    ///   - enableDevice: Collect device context (default: true)
    ///   - enableTime: Collect time context (default: true)
    ///   - enableAutoSession: Auto-track sessions (default: true)
    public init(
        apiKey: String,
        baseURL: String = "https://api.contextkit.dev/v1",
        uploadInterval: TimeInterval = 30.0,
        maxBatchSize: Int = 20,
        debugMode: Bool = false,
        enableGeo: Bool = true,
        enableDevice: Bool = true,
        enableTime: Bool = true,
        enableAutoSession: Bool = true
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.uploadInterval = uploadInterval
        self.maxBatchSize = maxBatchSize
        self.debugMode = debugMode
        self.enableGeo = enableGeo
        self.enableDevice = enableDevice
        self.enableTime = enableTime
        self.enableAutoSession = enableAutoSession
    }

    /// Test mode configuration (uses ck_test_ API key)
    public static func test(apiKey: String) -> ContextKitConfig {
        return ContextKitConfig(
            apiKey: apiKey,
            debugMode: true
        )
    }
}

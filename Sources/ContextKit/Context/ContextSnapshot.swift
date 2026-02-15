import Foundation

/// Complete context snapshot for an event
/// Combines time, geo, device, user, and session contexts
public struct ContextSnapshot: Codable, Sendable {
    /// Time context (hour, day of week, timezone, etc.)
    public let time: TimeContext

    /// Geographic and locale context
    public let geo: GeoContext

    /// Device hardware and state context
    public let device: DeviceContext

    /// User-specific context
    public let user: UserContext

    /// Session context
    public let session: SessionContext

    /// SDK version that captured this context
    public let sdkVersion: String

    /// Timestamp when context was captured
    public let capturedAt: Date

    /// Capture a complete context snapshot
    /// - Parameters:
    ///   - userManager: User context manager
    ///   - sessionManager: Session manager
    ///   - config: ContextKit configuration
    /// - Returns: Complete context snapshot
    static func capture(
        userManager: UserContextManager,
        sessionManager: SessionManager,
        config: ContextKitConfig
    ) async -> ContextSnapshot {
        // Capture time context (fast, synchronous)
        let time = config.enableTime ? TimeContext.capture() : TimeContext.empty()

        // Capture geo context (fast, synchronous)
        let geo = config.enableGeo ? GeoContext.capture() : GeoContext.empty()

        // Capture device context (fast, synchronous)
        let device = config.enableDevice ? DeviceContext.capture() : DeviceContext.empty()

        // Capture user context (async)
        let user = await userManager.capture()

        // Capture session context (async)
        let session = await sessionManager.capture()

        return ContextSnapshot(
            time: time,
            geo: geo,
            device: device,
            user: user,
            session: session,
            sdkVersion: ContextKitSDK.version,
            capturedAt: Date()
        )
    }

    private enum CodingKeys: String, CodingKey {
        case time
        case geo
        case device
        case user
        case session
        case sdkVersion = "sdk_version"
        case capturedAt = "captured_at"
    }
}

// Extensions for empty contexts when disabled
extension TimeContext {
    static func empty() -> TimeContext {
        return TimeContext(
            hour: 0,
            dayOfWeek: 1,
            isWeekend: false,
            timezone: "unknown",
            localTime: "00:00",
            dayPeriod: .night
        )
    }
}

extension GeoContext {
    static func empty() -> GeoContext {
        return GeoContext(
            countryCode: "unknown",
            region: "unknown",
            localeIdentifier: "unknown",
            currencyCode: "unknown",
            languageCode: "unknown"
        )
    }
}

extension DeviceContext {
    static func empty() -> DeviceContext {
        return DeviceContext(
            model: "unknown",
            osVersion: "unknown",
            screenWidth: 0,
            screenHeight: 0,
            screenScale: 1.0,
            batteryLevel: -1,
            batteryState: .unknown,
            networkType: .unknown,
            isLowPowerMode: false,
            availableDiskSpace: -1,
            totalMemory: 0
        )
    }
}

/// SDK version and metadata
enum ContextKitSDK {
    static let version = "1.0.0"
    static let name = "ContextKit"
}

import Foundation

/// User-specific context for an event
public struct UserContext: Codable, Sendable {
    /// User identifier (set by developer via identify())
    public let userId: String?

    /// User segment (e.g., "free", "paid", "trial")
    public let segment: String?

    /// Number of sessions this user has had
    public let sessionCount: Int

    /// Days since the app was first installed
    public let daysSinceInstall: Int

    /// Custom user properties set by developer
    public let customProperties: [String: String]

    /// Create a user context
    init(
        userId: String? = nil,
        segment: String? = nil,
        sessionCount: Int = 0,
        daysSinceInstall: Int = 0,
        customProperties: [String: String] = [:]
    ) {
        self.userId = userId
        self.segment = segment
        self.sessionCount = sessionCount
        self.daysSinceInstall = daysSinceInstall
        self.customProperties = customProperties
    }

    private enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case segment
        case sessionCount = "session_count"
        case daysSinceInstall = "days_since_install"
        case customProperties = "custom_properties"
    }
}

/// Manages user state persistence
actor UserContextManager {
    private let defaults = UserDefaults.standard
    private let installDateKey = "ContextKit.installDate"
    private let sessionCountKey = "ContextKit.sessionCount"
    private let userIdKey = "ContextKit.userId"
    private let userSegmentKey = "ContextKit.userSegment"
    private let userPropertiesKey = "ContextKit.userProperties"

    private var currentUserId: String?
    private var currentSegment: String?
    private var currentProperties: [String: String] = [:]

    init() {
        // Record install date if first launch
        if defaults.object(forKey: installDateKey) == nil {
            defaults.set(Date(), forKey: installDateKey)
        }

        // Load persisted user data
        currentUserId = defaults.string(forKey: userIdKey)
        currentSegment = defaults.string(forKey: userSegmentKey)
        if let data = defaults.data(forKey: userPropertiesKey),
           let properties = try? JSONDecoder().decode([String: String].self, from: data) {
            currentProperties = properties
        }
    }

    /// Increment session count
    func incrementSessionCount() {
        let count = defaults.integer(forKey: sessionCountKey) + 1
        defaults.set(count, forKey: sessionCountKey)
    }

    /// Set user identifier
    func setUserId(_ userId: String) {
        currentUserId = userId
        defaults.set(userId, forKey: userIdKey)
    }

    /// Set user segment
    func setSegment(_ segment: String) {
        currentSegment = segment
        defaults.set(segment, forKey: userSegmentKey)
    }

    /// Set user properties
    func setProperties(_ properties: [String: Any]) {
        // Convert to String dictionary for persistence
        let stringProperties = properties.compactMapValues { value -> String? in
            if let stringValue = value as? String {
                return stringValue
            } else if let number = value as? CustomStringConvertible {
                return number.description
            }
            return nil
        }

        currentProperties.merge(stringProperties) { _, new in new }

        if let data = try? JSONEncoder().encode(currentProperties) {
            defaults.set(data, forKey: userPropertiesKey)
        }
    }

    /// Capture current user context
    func capture() -> UserContext {
        let sessionCount = defaults.integer(forKey: sessionCountKey)
        let daysSinceInstall = calculateDaysSinceInstall()

        return UserContext(
            userId: currentUserId,
            segment: currentSegment,
            sessionCount: sessionCount,
            daysSinceInstall: daysSinceInstall,
            customProperties: currentProperties
        )
    }

    /// Calculate days since install
    private func calculateDaysSinceInstall() -> Int {
        guard let installDate = defaults.object(forKey: installDateKey) as? Date else {
            return 0
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: installDate, to: Date())
        return components.day ?? 0
    }
}

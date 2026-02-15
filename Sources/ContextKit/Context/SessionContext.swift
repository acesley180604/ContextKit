import Foundation

/// Session-specific context for an event
public struct SessionContext: Codable, Sendable {
    /// Unique session identifier
    public let sessionId: String

    /// Session duration in seconds
    public let duration: TimeInterval

    /// Number of screens viewed in this session
    public let screenViewCount: Int

    /// Number of events tracked in this session
    public let eventCount: Int

    /// First screen viewed in this session
    public let entryScreen: String?

    /// Create a session context
    init(
        sessionId: String,
        duration: TimeInterval,
        screenViewCount: Int,
        eventCount: Int,
        entryScreen: String?
    ) {
        self.sessionId = sessionId
        self.duration = duration
        self.screenViewCount = screenViewCount
        self.eventCount = eventCount
        self.entryScreen = entryScreen
    }

    private enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case duration
        case screenViewCount = "screen_view_count"
        case eventCount = "event_count"
        case entryScreen = "entry_screen"
    }
}

/// Manages session state
actor SessionManager {
    private var currentSessionId: String
    private var sessionStartTime: Date
    private var screenViewCount: Int = 0
    private var eventCount: Int = 0
    private var entryScreen: String?
    private var isActive: Bool = false

    init() {
        self.currentSessionId = UUID().uuidString
        self.sessionStartTime = Date()
    }

    /// Start a new session
    func startSession() {
        if !isActive {
            currentSessionId = UUID().uuidString
            sessionStartTime = Date()
            screenViewCount = 0
            eventCount = 0
            entryScreen = nil
            isActive = true
        }
    }

    /// End current session
    func endSession() {
        isActive = false
    }

    /// Track a screen view
    func trackScreenView(_ screenName: String) {
        if !isActive {
            startSession()
        }

        screenViewCount += 1
        if entryScreen == nil {
            entryScreen = screenName
        }
    }

    /// Increment event count
    func incrementEventCount() {
        if !isActive {
            startSession()
        }
        eventCount += 1
    }

    /// Capture current session context
    func capture() -> SessionContext {
        let duration = Date().timeIntervalSince(sessionStartTime)

        return SessionContext(
            sessionId: currentSessionId,
            duration: duration,
            screenViewCount: screenViewCount,
            eventCount: eventCount,
            entryScreen: entryScreen
        )
    }

    /// Get current session ID
    func getCurrentSessionId() -> String {
        return currentSessionId
    }

    /// Check if session is active
    func isSessionActive() -> Bool {
        return isActive
    }
}

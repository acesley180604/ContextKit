import Foundation

/// Represents a tracked event with full context
public struct ContextEvent: Codable, Sendable, Identifiable {
    /// Unique event identifier
    public let id: String

    /// Event name (e.g., "paywall_viewed", "purchase_completed")
    public let name: String

    /// Custom event properties provided by developer
    public let properties: [String: AnyCodable]

    /// Complete context snapshot at time of event
    public let context: ContextSnapshot

    /// Timestamp when event occurred
    public let timestamp: Date

    /// Create a new event
    init(
        name: String,
        properties: [String: Any],
        context: ContextSnapshot
    ) {
        self.id = UUID().uuidString
        self.name = name
        self.properties = properties.mapValues { AnyCodable($0) }
        self.context = context
        self.timestamp = Date()
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case properties
        case context
        case timestamp
    }
}

/// Type-erased wrapper for Codable values
public struct AnyCodable: Codable, Sendable {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported type"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            let context = EncodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Unsupported type"
            )
            throw EncodingError.invalidValue(value, context)
        }
    }
}

/// Screen view event (special type of event)
public struct ScreenViewEvent: Codable, Sendable {
    /// Screen name
    public let screenName: String

    /// Duration on screen in seconds
    public let duration: TimeInterval?

    /// Complete context snapshot
    public let context: ContextSnapshot

    /// Timestamp when screen was viewed
    public let timestamp: Date

    init(screenName: String, context: ContextSnapshot, duration: TimeInterval? = nil) {
        self.screenName = screenName
        self.duration = duration
        self.context = context
        self.timestamp = Date()
    }

    private enum CodingKeys: String, CodingKey {
        case screenName = "screen_name"
        case duration
        case context
        case timestamp
    }
}

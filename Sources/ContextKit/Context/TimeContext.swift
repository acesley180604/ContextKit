import Foundation

/// Time-of-day context for an event
public struct TimeContext: Codable, Sendable {
    /// Hour of the day in 24-hour format (0-23)
    public let hour: Int

    /// Day of the week (1 = Monday, 7 = Sunday)
    public let dayOfWeek: Int

    /// Whether this is a weekend day
    public let isWeekend: Bool

    /// Timezone identifier (e.g., "Asia/Hong_Kong", "America/Los_Angeles")
    public let timezone: String

    /// Local time in HH:mm format (e.g., "14:30", "09:15")
    public let localTime: String

    /// Period of the day
    public let dayPeriod: DayPeriod

    /// Represents different periods of the day
    public enum DayPeriod: String, Codable, Sendable {
        case morning    // 5-11
        case afternoon  // 12-16
        case evening    // 17-20
        case night      // 21-4

        /// Determine day period from hour
        static func from(hour: Int) -> DayPeriod {
            switch hour {
            case 5...11:
                return .morning
            case 12...16:
                return .afternoon
            case 17...20:
                return .evening
            default:
                return .night
            }
        }
    }

    /// Capture current time context
    /// - Returns: TimeContext with current device time information
    public static func capture() -> TimeContext {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .weekday], from: now)

        let hour = components.hour ?? 0
        let weekday = components.weekday ?? 1 // Sunday = 1, Saturday = 7

        // Convert to Monday=1, Sunday=7 format
        let dayOfWeek = weekday == 1 ? 7 : weekday - 1

        let isWeekend = (weekday == 1 || weekday == 7)

        let timezone = TimeZone.current.identifier

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
        let localTime = formatter.string(from: now)

        let dayPeriod = DayPeriod.from(hour: hour)

        return TimeContext(
            hour: hour,
            dayOfWeek: dayOfWeek,
            isWeekend: isWeekend,
            timezone: timezone,
            localTime: localTime,
            dayPeriod: dayPeriod
        )
    }

    private enum CodingKeys: String, CodingKey {
        case hour
        case dayOfWeek = "day_of_week"
        case isWeekend = "is_weekend"
        case timezone
        case localTime = "local_time"
        case dayPeriod = "day_period"
    }
}

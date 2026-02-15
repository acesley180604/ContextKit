import XCTest
@testable import ContextKit

final class TimeContextTests: XCTestCase {

    func testTimeContextCapture() {
        // Given
        let context = TimeContext.capture()

        // Then
        XCTAssertGreaterThanOrEqual(context.hour, 0)
        XCTAssertLessThanOrEqual(context.hour, 23)
        XCTAssertGreaterThanOrEqual(context.dayOfWeek, 1)
        XCTAssertLessThanOrEqual(context.dayOfWeek, 7)
        XCTAssertFalse(context.timezone.isEmpty)
        XCTAssertFalse(context.localTime.isEmpty)
    }

    func testDayPeriodMorning() {
        // Given/When
        let period = TimeContext.DayPeriod.from(hour: 8)

        // Then
        XCTAssertEqual(period, .morning)
    }

    func testDayPeriodAfternoon() {
        // Given/When
        let period = TimeContext.DayPeriod.from(hour: 14)

        // Then
        XCTAssertEqual(period, .afternoon)
    }

    func testDayPeriodEvening() {
        // Given/When
        let period = TimeContext.DayPeriod.from(hour: 19)

        // Then
        XCTAssertEqual(period, .evening)
    }

    func testDayPeriodNight() {
        // Given/When
        let periodLate = TimeContext.DayPeriod.from(hour: 23)
        let periodEarly = TimeContext.DayPeriod.from(hour: 3)

        // Then
        XCTAssertEqual(periodLate, .night)
        XCTAssertEqual(periodEarly, .night)
    }

    func testWeekendDetection() {
        // Given
        let context = TimeContext.capture()

        // Then
        // Weekend is Saturday (7) or Sunday (1 converted to 7)
        if context.dayOfWeek == 6 || context.dayOfWeek == 7 {
            XCTAssertTrue(context.isWeekend)
        } else {
            XCTAssertFalse(context.isWeekend)
        }
    }

    func testLocalTimeFormat() {
        // Given
        let context = TimeContext.capture()

        // Then
        // Local time should be in HH:mm format
        XCTAssertTrue(context.localTime.contains(":"))
        let components = context.localTime.split(separator: ":")
        XCTAssertEqual(components.count, 2)
    }
}

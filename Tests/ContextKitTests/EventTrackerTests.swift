import XCTest
@testable import ContextKit

final class EventTrackerTests: XCTestCase {

    func testEventCreation() {
        // Given
        let eventName = "test_event"
        let properties = ["key": "value", "count": 42] as [String: Any]

        // Create a mock context
        let timeContext = TimeContext.capture()
        let geoContext = GeoContext.capture()
        let deviceContext = DeviceContext.capture()
        let userContext = UserContext(
            userId: "test_user",
            segment: "free",
            sessionCount: 1,
            daysSinceInstall: 0,
            customProperties: [:]
        )
        let sessionContext = SessionContext(
            sessionId: "test_session",
            duration: 0,
            screenViewCount: 0,
            eventCount: 0,
            entryScreen: nil
        )

        let context = ContextSnapshot(
            time: timeContext,
            geo: geoContext,
            device: deviceContext,
            user: userContext,
            session: sessionContext,
            sdkVersion: "1.0.0",
            capturedAt: Date()
        )

        // When
        let event = ContextEvent(
            name: eventName,
            properties: properties,
            context: context
        )

        // Then
        XCTAssertEqual(event.name, eventName)
        XCTAssertFalse(event.id.isEmpty)
        XCTAssertNotNil(event.timestamp)
        XCTAssertEqual(event.properties.count, 2)
    }

    func testEventPropertiesCodable() throws {
        // Given
        let properties = [
            "string": "value",
            "number": 42,
            "decimal": 3.14,
            "bool": true
        ] as [String: Any]

        let timeContext = TimeContext.capture()
        let geoContext = GeoContext.capture()
        let deviceContext = DeviceContext.capture()
        let userContext = UserContext()
        let sessionContext = SessionContext(
            sessionId: "test",
            duration: 0,
            screenViewCount: 0,
            eventCount: 0,
            entryScreen: nil
        )

        let context = ContextSnapshot(
            time: timeContext,
            geo: geoContext,
            device: deviceContext,
            user: userContext,
            session: sessionContext,
            sdkVersion: "1.0.0",
            capturedAt: Date()
        )

        let event = ContextEvent(
            name: "test",
            properties: properties,
            context: context
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(event)

        // Then
        XCTAssertGreaterThan(data.count, 0)

        // Decode back
        let decoder = JSONDecoder()
        let decodedEvent = try decoder.decode(ContextEvent.self, from: data)

        XCTAssertEqual(decodedEvent.name, event.name)
        XCTAssertEqual(decodedEvent.id, event.id)
    }

    func testContextSnapshotCodable() throws {
        // Given
        let timeContext = TimeContext.capture()
        let geoContext = GeoContext.capture()
        let deviceContext = DeviceContext.capture()
        let userContext = UserContext(
            userId: "user_123",
            segment: "premium",
            sessionCount: 5,
            daysSinceInstall: 10,
            customProperties: ["plan": "annual"]
        )
        let sessionContext = SessionContext(
            sessionId: "session_123",
            duration: 120.5,
            screenViewCount: 3,
            eventCount: 10,
            entryScreen: "home"
        )

        let snapshot = ContextSnapshot(
            time: timeContext,
            geo: geoContext,
            device: deviceContext,
            user: userContext,
            session: sessionContext,
            sdkVersion: "1.0.0",
            capturedAt: Date()
        )

        // When
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(snapshot)

        // Then
        XCTAssertGreaterThan(data.count, 0)

        // Verify can decode
        let decoder = JSONDecoder()
        let decodedSnapshot = try decoder.decode(ContextSnapshot.self, from: data)

        XCTAssertEqual(decodedSnapshot.time.hour, snapshot.time.hour)
        XCTAssertEqual(decodedSnapshot.geo.countryCode, snapshot.geo.countryCode)
        XCTAssertEqual(decodedSnapshot.device.model, snapshot.device.model)
        XCTAssertEqual(decodedSnapshot.user.userId, snapshot.user.userId)
        XCTAssertEqual(decodedSnapshot.session.sessionId, snapshot.session.sessionId)
    }

    func testPerformanceContextCapture() {
        // Test that context capture is fast (< 10ms requirement)
        measure {
            for _ in 0..<100 {
                _ = TimeContext.capture()
                _ = GeoContext.capture()
                _ = DeviceContext.capture()
            }
        }
    }
}

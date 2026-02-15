import XCTest
@testable import ContextKit

final class DeviceContextTests: XCTestCase {

    func testDeviceContextCapture() {
        // Given/When
        let context = DeviceContext.capture()

        // Then
        XCTAssertFalse(context.model.isEmpty)
        XCTAssertFalse(context.osVersion.isEmpty)
        XCTAssertGreaterThan(context.totalMemory, 0)
    }

    func testScreenDimensions() {
        // Given/When
        let context = DeviceContext.capture()

        // Then
        #if os(iOS)
        XCTAssertGreaterThan(context.screenWidth, 0)
        XCTAssertGreaterThan(context.screenHeight, 0)
        XCTAssertGreaterThanOrEqual(context.screenScale, 1.0)
        XCTAssertLessThanOrEqual(context.screenScale, 3.0)
        #endif
    }

    func testBatteryLevel() {
        // Given/When
        let context = DeviceContext.capture()

        // Then
        // Battery level should be between 0 and 1, or -1 if unavailable
        if context.batteryLevel >= 0 {
            XCTAssertGreaterThanOrEqual(context.batteryLevel, 0.0)
            XCTAssertLessThanOrEqual(context.batteryLevel, 1.0)
        } else {
            XCTAssertEqual(context.batteryLevel, -1.0)
        }
    }

    func testBatteryState() {
        // Given/When
        let context = DeviceContext.capture()

        // Then
        let validStates: [DeviceContext.BatteryState] = [
            .unknown, .unplugged, .charging, .full
        ]
        XCTAssertTrue(validStates.contains(context.batteryState))
    }

    func testNetworkType() {
        // Given/When
        let context = DeviceContext.capture()

        // Then
        let validTypes: [DeviceContext.NetworkType] = [
            .unknown, .wifi, .cellular, .offline
        ]
        XCTAssertTrue(validTypes.contains(context.networkType))
    }

    func testLowPowerMode() {
        // Given/When
        let context = DeviceContext.capture()

        // Then
        // Should be a valid boolean
        XCTAssertNotNil(context.isLowPowerMode)
    }

    func testMemory() {
        // Given/When
        let context = DeviceContext.capture()

        // Then
        // Total memory should be reasonable (at least 1GB, max 64GB)
        let oneGB: UInt64 = 1_000_000_000
        let sixtyFourGB: UInt64 = 64_000_000_000
        XCTAssertGreaterThan(context.totalMemory, oneGB)
        XCTAssertLessThan(context.totalMemory, sixtyFourGB)
    }
}

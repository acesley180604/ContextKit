import XCTest
@testable import ContextKit

final class GeoContextTests: XCTestCase {

    func testGeoContextCapture() {
        // Given/When
        let context = GeoContext.capture()

        // Then
        XCTAssertFalse(context.countryCode.isEmpty)
        XCTAssertFalse(context.region.isEmpty)
        XCTAssertFalse(context.localeIdentifier.isEmpty)
        XCTAssertFalse(context.currencyCode.isEmpty)
        XCTAssertFalse(context.languageCode.isEmpty)
    }

    func testRegionMapping() {
        // Test that region computation works for known countries
        // This is a simple smoke test

        let context = GeoContext.capture()

        // Region should be one of the known regions
        let validRegions = [
            "Asia-Pacific",
            "Europe",
            "North America",
            "South America",
            "Middle East",
            "Africa",
            "Other"
        ]

        XCTAssertTrue(validRegions.contains(context.region))
    }

    func testCountryCodeFormat() {
        // Given/When
        let context = GeoContext.capture()

        // Then
        // Country code should be 2 characters or "unknown"
        if context.countryCode != "unknown" {
            XCTAssertEqual(context.countryCode.count, 2)
            XCTAssertEqual(context.countryCode, context.countryCode.uppercased())
        }
    }

    func testCurrencyCodeFormat() {
        // Given/When
        let context = GeoContext.capture()

        // Then
        // Currency code should be 3 characters (ISO 4217)
        if context.currencyCode != "unknown" {
            XCTAssertEqual(context.currencyCode.count, 3)
            XCTAssertEqual(context.currencyCode, context.currencyCode.uppercased())
        }
    }

    func testLanguageCodeFormat() {
        // Given/When
        let context = GeoContext.capture()

        // Then
        // Language code should be 2-3 characters
        if context.languageCode != "unknown" {
            XCTAssertGreaterThanOrEqual(context.languageCode.count, 2)
            XCTAssertLessThanOrEqual(context.languageCode.count, 3)
        }
    }
}

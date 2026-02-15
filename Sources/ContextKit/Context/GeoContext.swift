import Foundation

/// Geographic and locale context for an event
/// IMPORTANT: Uses Locale.current only - NO location permissions required
public struct GeoContext: Codable, Sendable {
    /// ISO country code (e.g., "US", "JP", "DE")
    public let countryCode: String

    /// Geographic region (e.g., "Asia", "Europe", "Americas")
    public let region: String

    /// Locale identifier (e.g., "en_US", "ja_JP")
    public let localeIdentifier: String

    /// ISO currency code (e.g., "USD", "JPY", "EUR")
    public let currencyCode: String

    /// ISO language code (e.g., "en", "ja", "de")
    public let languageCode: String

    /// Capture current geo context from device locale
    /// - Returns: GeoContext based on Locale.current
    public static func capture() -> GeoContext {
        let locale = Locale.current

        let countryCode = locale.region?.identifier ?? "unknown"
        let region = computeRegion(from: countryCode)
        let localeIdentifier = locale.identifier
        let currencyCode = locale.currency?.identifier ?? "USD"
        let languageCode = locale.language.languageCode?.identifier ?? "en"

        return GeoContext(
            countryCode: countryCode,
            region: region,
            localeIdentifier: localeIdentifier,
            currencyCode: currencyCode,
            languageCode: languageCode
        )
    }

    /// Compute geographic region from country code
    private static func computeRegion(from countryCode: String) -> String {
        // Asia-Pacific
        let asiaPacific = ["CN", "JP", "KR", "TW", "HK", "SG", "TH", "VN", "ID", "MY", "PH", "IN", "AU", "NZ"]
        if asiaPacific.contains(countryCode) {
            return "Asia-Pacific"
        }

        // Europe
        let europe = ["GB", "DE", "FR", "IT", "ES", "NL", "SE", "NO", "DK", "FI", "PL", "CH", "AT", "BE", "IE", "PT", "CZ", "GR", "RO", "HU"]
        if europe.contains(countryCode) {
            return "Europe"
        }

        // North America
        let northAmerica = ["US", "CA", "MX"]
        if northAmerica.contains(countryCode) {
            return "North America"
        }

        // South America
        let southAmerica = ["BR", "AR", "CL", "CO", "PE", "VE", "EC", "BO", "PY", "UY"]
        if southAmerica.contains(countryCode) {
            return "South America"
        }

        // Middle East
        let middleEast = ["AE", "SA", "IL", "TR", "EG", "QA", "KW", "BH", "OM", "JO", "LB"]
        if middleEast.contains(countryCode) {
            return "Middle East"
        }

        // Africa
        let africa = ["ZA", "NG", "KE", "GH", "TZ", "UG", "ZW", "ET", "MA", "DZ", "TN"]
        if africa.contains(countryCode) {
            return "Africa"
        }

        return "Other"
    }

    private enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case region
        case localeIdentifier = "locale_identifier"
        case currencyCode = "currency_code"
        case languageCode = "language_code"
    }
}

import Foundation

/// Network client for ContextKit API
actor APIClient {
    private let config: ContextKitConfig
    private let session: URLSession
    private var uploadAttempts: [String: Int] = [:] // Track retry attempts

    init(config: ContextKitConfig) {
        self.config = config

        // Configure URLSession for background uploads
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 30.0
        configuration.httpMaximumConnectionsPerHost = 3
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData

        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Public API

    /// Upload batch of events
    func uploadEvents(_ events: [ContextEvent]) async throws {
        let payload = EventBatchPayload(
            apiKey: config.apiKey,
            events: events,
            sdkVersion: ContextKitSDK.version,
            uploadedAt: Date()
        )

        let endpoint = "\(config.baseURL)/events"
        try await postRequest(endpoint: endpoint, payload: payload)
    }

    /// Fetch insights for app (Phase 2)
    func fetchInsights(appId: String) async throws -> [Insight] {
        let endpoint = "\(config.baseURL)/apps/\(appId)/insights"
        return try await getRequest(endpoint: endpoint)
    }

    /// Fetch recommendations (Phase 2)
    func fetchRecommendations(appId: String, screen: String?, market: String?) async throws -> [Recommendation] {
        var endpoint = "\(config.baseURL)/apps/\(appId)/recommendations"

        var queryItems: [String] = []
        if let screen = screen {
            queryItems.append("screen=\(screen)")
        }
        if let market = market {
            queryItems.append("market=\(market)")
        }

        if !queryItems.isEmpty {
            endpoint += "?" + queryItems.joined(separator: "&")
        }

        return try await getRequest(endpoint: endpoint)
    }

    // MARK: - Request Methods

    private func postRequest<T: Encodable>(endpoint: String, payload: T) async throws {
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(config.apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("ContextKit-iOS/\(ContextKitSDK.version)", forHTTPHeaderField: "User-Agent")

        // Encode payload
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(payload)

        // Compress if large
        if let body = request.httpBody, body.count > 1024 {
            request.httpBody = try? compress(data: body)
            request.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
        }

        // Execute with retry logic
        try await executeWithRetry(request: request)
    }

    private func getRequest<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(config.apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("ContextKit-iOS/\(ContextKitSDK.version)", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(T.self, from: data)
    }

    // MARK: - Retry Logic

    private func executeWithRetry(request: URLRequest, attempt: Int = 1) async throws {
        do {
            let (_, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            if (200...299).contains(httpResponse.statusCode) {
                // Success - reset retry count
                if let url = request.url?.absoluteString {
                    uploadAttempts[url] = 0
                }
                return
            } else if httpResponse.statusCode >= 500 && attempt < 3 {
                // Server error - retry with backoff
                let delay = exponentialBackoff(attempt: attempt)
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                try await executeWithRetry(request: request, attempt: attempt + 1)
            } else {
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }
        } catch {
            if attempt < 3 {
                // Network error - retry with backoff
                let delay = exponentialBackoff(attempt: attempt)
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                try await executeWithRetry(request: request, attempt: attempt + 1)
            } else {
                throw error
            }
        }
    }

    private func exponentialBackoff(attempt: Int) -> TimeInterval {
        // 1s, 2s, 4s
        return pow(2.0, Double(attempt - 1))
    }

    // MARK: - Compression

    private func compress(data: Data) throws -> Data {
        #if canImport(Compression)
        return try (data as NSData).compressed(using: .zlib) as Data
        #else
        return data
        #endif
    }
}

// MARK: - API Error Types

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case encodingError
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .encodingError:
            return "Failed to encode request"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

// MARK: - Payload Models

struct EventBatchPayload: Codable {
    let apiKey: String
    let events: [ContextEvent]
    let sdkVersion: String
    let uploadedAt: Date

    private enum CodingKeys: String, CodingKey {
        case apiKey = "api_key"
        case events
        case sdkVersion = "sdk_version"
        case uploadedAt = "uploaded_at"
    }
}

/// AI-generated insight (Phase 2)
public struct Insight: Codable, Sendable {
    public let type: InsightType
    public let message: String
    public let severity: Severity
    public let affectedContext: [String: String]
    public let recommendation: String?

    public enum InsightType: String, Codable, Sendable {
        case anomaly
        case trend
        case benchmark
        case opportunity
    }

    public enum Severity: String, Codable, Sendable {
        case low
        case medium
        case high
        case critical
    }
}

/// AI-generated recommendation (Phase 2)
public struct Recommendation: Codable, Sendable {
    public let action: String
    public let confidence: Double
    public let benchmark: String?
    public let expectedImpact: String?

    private enum CodingKeys: String, CodingKey {
        case action
        case confidence
        case benchmark
        case expectedImpact = "expected_impact"
    }
}

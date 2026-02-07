import Foundation

/// Async/await API client using URLSession — no third-party dependencies.
actor APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfig.timeout
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        // Backend uses camelCase JSON keys
        self.decoder.keyDecodingStrategy = .useDefaultKeys
    }

    // MARK: - Generic Request

    /// Perform a request and decode the response.
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        body: (any Encodable)? = nil
    ) async throws -> T {
        guard let url = endpoint.url() else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method

        for (key, value) in APIConfig.defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        var (data, response): (Data, URLResponse)
        if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, visionOS 1.0, *) {
            // Preferred async/await API available across modern OS versions
            (data, response) = try await session.data(for: request)
        } else {
            // Fallback for older platforms that don't support async/await or continuations.
            // Use a continuation to bridge the completion handler API without blocking.
            let result: (Data, URLResponse) = try await withCheckedThrowingContinuation { continuation in
                let task = session.dataTask(with: request) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let data = data, let response = response else {
                        continuation.resume(throwing: APIError.invalidResponse)
                        return
                    }
                    continuation.resume(returning: (data, response))
                }
                task.resume()
            }
            data = result.0
            response = result.1
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(
                statusCode: httpResponse.statusCode,
                body: String(data: data, encoding: .utf8)
            )
        }

        return try decoder.decode(T.self, from: data)
    }

    // MARK: - Node Persons

    func fetchNodePersons(
        nodeType: String? = nil,
        region: String? = nil
    ) async throws -> [NodePerson] {
        try await request(.listNodePersons(nodeType: nodeType, region: region))
    }

    func fetchNodePerson(id: String) async throws -> NodePerson {
        try await request(.getNodePerson(id: id))
    }

    func fetchLeaderboard(limit: Int = 10) async throws -> [LeaderboardEntry] {
        try await request(.leaderboard(limit: limit))
    }

    func fetchStats() async throws -> [NodeTypeStats] {
        try await request(.nodePersonStats)
    }

    // MARK: - Conversation Scripts

    func fetchScripts(
        nodeType: String? = nil
    ) async throws -> [ConversationScript] {
        try await request(.conversationScripts(nodeType: nodeType))
    }

    func fetchCorePrinciple() async throws -> CorePrinciple {
        try await request(.corePrinciple)
    }
}

// MARK: - Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, body: String?)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code, let body):
            return "HTTP \(code): \(body ?? "Unknown error")"
        }
    }
}


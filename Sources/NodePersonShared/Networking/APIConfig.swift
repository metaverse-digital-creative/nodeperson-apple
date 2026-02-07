import Foundation

/// API configuration for connecting to the leads-platform backend.
enum APIConfig {
    /// Base URL for the NestJS backend.
    /// Change this to your machine's IP for real device testing.
    static let baseURL = "http://localhost:3000"

    /// Community API prefix (includes NestJS global prefix)
    static let communityPath = "/api/v1/community"

    /// Default request timeout (seconds)
    static let timeout: TimeInterval = 30

    /// Common headers
    static let defaultHeaders: [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json",
    ]
}

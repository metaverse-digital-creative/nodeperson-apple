import Foundation

/// API configuration for connecting to the recycling-leads-platform backend.
enum APIConfig {
    /// Base URL for the Express backend.
    /// Change this to your machine's IP for real device testing.
    static let baseURL = "http://localhost:5001"

    /// Community API prefix
    static let communityPath = "/api/community"

    /// Default request timeout (seconds)
    static let timeout: TimeInterval = 30

    /// Common headers
    static let defaultHeaders: [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json",
    ]
}

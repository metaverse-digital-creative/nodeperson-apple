import Foundation

/// Defines all API endpoints for the community module.
enum APIEndpoint {
    // Node Persons
    case listNodePersons(nodeType: String? = nil, region: String? = nil)
    case getNodePerson(id: String)
    case createNodePerson
    case updateNodePerson(id: String)
    case deleteNodePerson(id: String)
    case leaderboard(limit: Int = 10)
    case nodePersonStats
    case recalculateInfluence(id: String)

    // Conversation Scripts
    case conversationScripts(nodeType: String? = nil)
    case conversationScript(id: String)
    case corePrinciple

    // Referrals
    case referralStats

    /// HTTP method
    var method: String {
        switch self {
        case .createNodePerson, .recalculateInfluence:
            return "POST"
        case .updateNodePerson:
            return "PATCH"
        case .deleteNodePerson:
            return "DELETE"
        default:
            return "GET"
        }
    }

    /// URL path (appended to base + community prefix)
    var path: String {
        switch self {
        case .listNodePersons:
            return "/node-persons"
        case .getNodePerson(let id):
            return "/node-persons/\(id)"
        case .createNodePerson:
            return "/node-persons"
        case .updateNodePerson(let id):
            return "/node-persons/\(id)"
        case .deleteNodePerson(let id):
            return "/node-persons/\(id)"
        case .leaderboard:
            return "/node-persons/leaderboard"
        case .nodePersonStats:
            return "/node-persons/stats"
        case .recalculateInfluence(let id):
            return "/node-persons/\(id)/recalculate"
        case .conversationScripts:
            return "/conversation-scripts"
        case .conversationScript(let id):
            return "/conversation-scripts/\(id)"
        case .corePrinciple:
            return "/conversation-scripts/principle"
        case .referralStats:
            return "/referrals/stats"
        }
    }

    /// Query parameters
    var queryItems: [URLQueryItem]? {
        switch self {
        case .listNodePersons(let nodeType, let region):
            var items: [URLQueryItem] = []
            if let nodeType { items.append(.init(name: "nodeType", value: nodeType)) }
            if let region { items.append(.init(name: "region", value: region)) }
            return items.isEmpty ? nil : items
        case .conversationScripts(let nodeType):
            guard let nodeType else { return nil }
            return [.init(name: "nodeType", value: nodeType)]
        case .leaderboard(let limit):
            return [.init(name: "limit", value: String(limit))]
        default:
            return nil
        }
    }

    /// Build the full URL
    func url() -> URL? {
        var components = URLComponents(
            string: APIConfig.baseURL + APIConfig.communityPath + path
        )
        components?.queryItems = queryItems
        return components?.url
    }
}

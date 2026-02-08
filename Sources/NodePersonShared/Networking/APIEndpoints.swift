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

    // ─── Green Karma Score ───
    case karmaLeaderboard(limit: Int = 20, region: String? = nil)
    case karma(nodePersonId: String)
    case refreshKarma(nodePersonId: String)
    case refreshAllKarma

    // ─── Events (茶會功能) ───
    case listEvents(region: String? = nil)
    case eventStats(region: String? = nil)
    case getEvent(id: String)
    case createEvent
    case checkIn(eventId: String)
    case completeEvent(id: String)
    case cancelEvent(id: String)
    case hostEvents(nodePersonId: String)

    // ─── Waste Matching (一鍵媒合) ───
    case classifyWaste
    case createWastePost
    case listWastePosts(category: String? = nil, status: String? = nil)
    case getWastePost(id: String)
    case wastePostMatches(postId: String)
    case acceptWasteMatch(matchId: String)
    case completeWasteMatch(matchId: String)
    case wasteStats

    /// HTTP method
    var method: String {
        switch self {
        case .createNodePerson, .recalculateInfluence,
             .refreshKarma, .refreshAllKarma,
             .createEvent, .checkIn, .completeEvent,
             .classifyWaste, .createWastePost, .acceptWasteMatch, .completeWasteMatch:
            return "POST"
        case .updateNodePerson:
            return "PATCH"
        case .deleteNodePerson, .cancelEvent:
            return "DELETE"
        default:
            return "GET"
        }
    }

    /// URL path (appended to base URL)
    var path: String {
        switch self {
        // Node Persons
        case .listNodePersons:
            return "/community/node-persons"
        case .getNodePerson(let id):
            return "/community/node-persons/\(id)"
        case .createNodePerson:
            return "/community/node-persons"
        case .updateNodePerson(let id):
            return "/community/node-persons/\(id)"
        case .deleteNodePerson(let id):
            return "/community/node-persons/\(id)"
        case .leaderboard:
            return "/community/node-persons/leaderboard"
        case .nodePersonStats:
            return "/community/node-persons/stats"
        case .recalculateInfluence(let id):
            return "/community/node-persons/\(id)/recalculate"

        // Scripts
        case .conversationScripts:
            return "/community/conversation-scripts"
        case .conversationScript(let id):
            return "/community/conversation-scripts/\(id)"
        case .corePrinciple:
            return "/community/conversation-scripts/principle"

        // Referrals
        case .referralStats:
            return "/community/referrals/stats"

        // Karma
        case .karmaLeaderboard:
            return "/community/karma/leaderboard"
        case .karma(let nodePersonId):
            return "/community/karma/\(nodePersonId)"
        case .refreshKarma(let nodePersonId):
            return "/community/karma/\(nodePersonId)/refresh"
        case .refreshAllKarma:
            return "/community/karma/refresh-all"

        // Events
        case .listEvents:
            return "/events"
        case .eventStats:
            return "/events/stats"
        case .getEvent(let id):
            return "/events/\(id)"
        case .createEvent:
            return "/events"
        case .checkIn(let eventId):
            return "/events/\(eventId)/check-in"
        case .completeEvent(let id):
            return "/events/\(id)/complete"
        case .cancelEvent(let id):
            return "/events/\(id)"
        case .hostEvents(let nodePersonId):
            return "/events/host/\(nodePersonId)"

        // Waste
        case .classifyWaste:
            return "/waste/classify"
        case .createWastePost:
            return "/waste/posts"
        case .listWastePosts:
            return "/waste/posts"
        case .getWastePost(let id):
            return "/waste/posts/\(id)"
        case .wastePostMatches(let postId):
            return "/waste/posts/\(postId)/matches"
        case .acceptWasteMatch(let matchId):
            return "/waste/matches/\(matchId)/accept"
        case .completeWasteMatch(let matchId):
            return "/waste/matches/\(matchId)/complete"
        case .wasteStats:
            return "/waste/stats"
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
        case .karmaLeaderboard(let limit, let region):
            var items: [URLQueryItem] = [.init(name: "limit", value: String(limit))]
            if let region { items.append(.init(name: "region", value: region)) }
            return items
        case .listEvents(let region):
            guard let region else { return nil }
            return [.init(name: "region", value: region)]
        case .eventStats(let region):
            guard let region else { return nil }
            return [.init(name: "region", value: region)]
        case .listWastePosts(let category, let status):
            var items: [URLQueryItem] = []
            if let category { items.append(.init(name: "category", value: category)) }
            if let status { items.append(.init(name: "status", value: status)) }
            return items.isEmpty ? nil : items
        default:
            return nil
        }
    }

    /// Build the full URL
    func url() -> URL? {
        var components = URLComponents(
            string: APIConfig.baseURL + path
        )
        components?.queryItems = queryItems
        return components?.url
    }
}

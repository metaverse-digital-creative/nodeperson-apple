import Foundation

/// A trust relay station node in the community network.
struct NodePerson: Codable, Identifiable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?

    // Identity
    let name: String
    let phone: String?
    let lineUserId: String?

    // Type
    let nodeType: String
    let nodeTypeLabel: String?

    // Influence metrics
    let influenceScore: Double
    let communityLinks: Int
    let referralCount: Int
    let successfulMatches: Int
    let reachEstimate: Int

    // Location
    let district: String?
    let region: String?

    // Activity
    let isActive: Bool
    let lastActiveAt: String?
    let notes: String?

    // Relations (optional, included when fetched with details)
    let referrals: [Referral]?

    /// Parsed node type enum
    var nodeTypeEnum: NodeType? {
        NodeType(rawValue: nodeType)
    }

    /// Display label (falls back to nodeTypeLabel or raw type)
    var displayTypeLabel: String {
        nodeTypeEnum?.label ?? nodeTypeLabel ?? nodeType
    }

    /// Influence level description
    var influenceLevel: String {
        switch influenceScore {
        case 80...: return "極高影響力"
        case 60..<80: return "高影響力"
        case 40..<60: return "中等影響力"
        case 20..<40: return "建立中"
        default: return "初始階段"
        }
    }
}

/// A referral record linked to a NodePerson
struct Referral: Codable, Identifiable {
    let id: String
    let createdAt: String
    let referrerUserId: String?
    let referrerNodePerson: String?
    let refereeUserId: String
    let source: String?
    let campaign: String?
    let converted: Bool
    let convertedAt: String?
    let matchId: String?
}

/// Leaderboard entry (subset of NodePerson fields)
struct LeaderboardEntry: Codable, Identifiable {
    let id: String
    let name: String
    let nodeType: String
    let nodeTypeLabel: String?
    let influenceScore: Double
    let communityLinks: Int
    let referralCount: Int
    let successfulMatches: Int
    let district: String?
    let region: String?

    var nodeTypeEnum: NodeType? {
        NodeType(rawValue: nodeType)
    }
}

/// Statistics by node type
struct NodeTypeStats: Codable {
    let nodeType: String
    let label: String
    let count: Int
    let avgInfluence: Double
    let totalReferrals: Int
    let totalSuccessfulMatches: Int
}

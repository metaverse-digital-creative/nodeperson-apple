import Foundation

/// Green Karma Score — the multi-dimensional community impact metric.
///
/// Formula (weights):
///   totalKarma = recycling × 0.35 + referral × 0.25 + community × 0.20 + trust × 0.20
struct KarmaScore: Codable {
    let recyclingScore: Double
    let referralScore: Double
    let communityScore: Double
    let trustScore: Double
    let totalKarma: Double
    let weeklyDelta: Double
    let activeStreak: Int
    let level: Int

    /// Formatted delta string (e.g. "+3.5" or "-1.2")
    var deltaString: String {
        weeklyDelta >= 0 ? "+\(String(format: "%.1f", weeklyDelta))" : String(format: "%.1f", weeklyDelta)
    }

    /// Level emoji
    var levelEmoji: String {
        switch level {
        case 1: return "🌱"
        case 2: return "🌿"
        case 3: return "🌳"
        case 4: return "🌲"
        case 5: return "⭐"
        case 6: return "🌟"
        case 7: return "💫"
        case 8: return "🔥"
        case 9: return "💎"
        case 10: return "👑"
        default: return "🌱"
        }
    }

    /// Level title
    var levelTitle: String {
        switch level {
        case 1...2: return "社區新苗"
        case 3...4: return "綠色守護者"
        case 5...6: return "影響力節點"
        case 7...8: return "社區之星"
        case 9...10: return "永續大使"
        default: return "社區新苗"
        }
    }
}

/// Karma leaderboard entry from the API
struct KarmaLeaderboardEntry: Codable, Identifiable {
    let rank: Int
    let nodePersonId: String
    let name: String
    let nodeType: String
    let nodeTypeLabel: String?
    let district: String?
    let region: String?
    let totalKarma: Double
    let level: Int
    let weeklyDelta: Double
    let activeStreak: Int
    let breakdown: KarmaBreakdown

    var id: String { nodePersonId }
}

struct KarmaBreakdown: Codable {
    let recycling: Double
    let referral: Double
    let community: Double
    let trust: Double
}

/// Karma history snapshot for trend visualization
struct KarmaHistoryEntry: Codable, Identifiable {
    let id: String
    let snapshotWeek: String
    let recyclingScore: Double
    let referralScore: Double
    let communityScore: Double
    let trustScore: Double
    let totalKarma: Double
    let level: Int
}

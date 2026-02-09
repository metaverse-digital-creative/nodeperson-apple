import Foundation

/// Green Karma Score — the multi-dimensional contribution record (貢獻紀錄).
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

    /// Preview / offline fallback data
    static let preview = KarmaScore(
        recyclingScore: 72,
        referralScore: 45,
        communityScore: 88,
        trustScore: 65,
        totalKarma: 67.5,
        weeklyDelta: 3.2,
        activeStreak: 5,
        level: 7
    )
}

/// A single contribution record entry (replaces leaderboard concept — 貢獻紀錄, 非排行榜)
struct ContributionRecord: Codable, Identifiable {
    let id: String
    let nodePersonId: String
    let type: String        // recycling | referral | community | trust
    let description: String
    let karmaPoints: Double
    let timestamp: String

    var typeEmoji: String {
        switch type {
        case "recycling": return "♻️"
        case "referral":  return "🤝"
        case "community": return "🏘️"
        case "trust":     return "💎"
        default:          return "✨"
        }
    }

    var typeColor: String {
        switch type {
        case "recycling": return "green"
        case "referral":  return "orange"
        case "community": return "blue"
        case "trust":     return "purple"
        default:          return "gray"
        }
    }
}

/// API response for contribution history
struct ContributionResponse: Codable {
    let nodePersonId: String
    let total: Int
    let records: [ContributionRecord]
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

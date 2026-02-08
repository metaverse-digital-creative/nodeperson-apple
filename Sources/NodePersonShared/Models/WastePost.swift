import Foundation

/// A waste post for the 一鍵媒合 feature.
struct WastePost: Codable, Identifiable {
    let id: String
    let createdAt: String
    let updatedAt: String

    let posterNodePersonId: String
    let photoUrl: String
    let aiCategory: String
    let aiConfidence: Double
    let weightKg: Double?
    let description: String?
    let latitude: Double?
    let longitude: Double?
    let status: String  // 'open', 'matched', 'completed', 'expired'

    let matches: [WasteMatch]?
    let posterNodePerson: WastePoster?

    /// Display category label
    var categoryLabel: String {
        switch aiCategory {
        case "plastic": return "塑膠"
        case "metal": return "金屬"
        case "paper": return "紙類"
        case "electronics": return "電子"
        case "organic": return "有機"
        case "glass": return "玻璃"
        case "textile": return "紡織"
        case "mixed": return "混合"
        default: return aiCategory
        }
    }

    /// Category emoji
    var categoryEmoji: String {
        switch aiCategory {
        case "plastic": return "♻️"
        case "metal": return "🔩"
        case "paper": return "📄"
        case "electronics": return "💻"
        case "organic": return "🌿"
        case "glass": return "🪟"
        case "textile": return "👕"
        case "mixed": return "📦"
        default: return "❓"
        }
    }

    var statusLabel: String {
        switch status {
        case "open": return "等待媒合"
        case "matched": return "已媒合"
        case "completed": return "已完成"
        case "expired": return "已過期"
        default: return status
        }
    }
}

struct WastePoster: Codable {
    let id: String
    let name: String
    let nodeType: String
    let district: String?
}

/// A buyer match for a waste post.
struct WasteMatch: Codable, Identifiable {
    let id: String
    let createdAt: String
    let wastePostId: String
    let buyerExternalId: String
    let buyerName: String
    let offeredPrice: Double?
    let agreedPrice: Double?
    let commissionRate: Double
    let commissionTotal: Double?
    let communityFund: Double?
    let platformFund: Double?
    let status: String  // 'pending', 'accepted', 'completed', 'rejected'

    var statusLabel: String {
        switch status {
        case "pending": return "待確認"
        case "accepted": return "已接受"
        case "completed": return "已完成"
        case "rejected": return "已拒絕"
        default: return status
        }
    }
}

/// AI classification result.
struct WasteClassification: Codable {
    let category: String
    let confidence: Double
    let suggestedBuyers: [SuggestedBuyer]?
}

struct SuggestedBuyer: Codable, Identifiable {
    let id: String?
    let name: String?
    let company: String?
    let pricePerKg: Double?

    var displayName: String {
        name ?? company ?? "Unknown"
    }
}

/// Waste matching statistics.
struct WasteStats: Codable {
    let totalPosts: Int
    let matched: Int
    let completed: Int
    let totalTransactionValue: Double
    let totalCommission: Double
    let totalCommunityFund: Double
    let totalPlatformFund: Double
}

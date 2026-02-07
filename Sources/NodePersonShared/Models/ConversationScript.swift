import Foundation

/// A conversation script for approaching a specific NodePerson type.
///
/// Core principle:
///   ❌「你有沒有東西要賣？」
///   ✅「最近有沒有誰在煩惱怎麼處理？」
///   👉 問的是煩惱，不是商品。
struct ConversationScript: Codable, Identifiable {
    let id: String
    let nodeType: String
    let nodeTypeLabel: String
    let whyCritical: String
    let correctOpener: String
    let antiPattern: String
    let followUps: [String]
    let signalType: String
    let locale: String

    var nodeTypeEnum: NodeType? {
        NodeType(rawValue: nodeType)
    }
}

/// The core principle displayed prominently across all platforms.
struct CorePrinciple: Codable {
    let title: String
    let subtitle: String
    let doNot: String
    let doThis: String
    let explanation: String
}

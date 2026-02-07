import Foundation

/// All NodePerson types in the trust relay station network.
///
/// Each city has 5-7 NodePersons. They are NOT KOLs —
/// they are "trust relay stations" (信任中繼站).
enum NodeType: String, Codable, CaseIterable, Identifiable {
    case liZhang = "li_zhang"
    case farmersAssoc = "farmers_assoc"
    case temple = "temple"
    case opinionLeader = "opinion_leader"
    case factoryMaster = "factory_master"
    case repairTech = "repair_tech"
    case contractor = "contractor"

    var id: String { rawValue }

    /// Chinese display label
    var label: String {
        switch self {
        case .liZhang:       return "里長"
        case .farmersAssoc:  return "農會 / 協會"
        case .temple:        return "廟宇 / 宮廟"
        case .opinionLeader: return "意見領袖"
        case .factoryMaster: return "工廠老師傅"
        case .repairTech:    return "修理師"
        case .contractor:    return "包商"
        }
    }

    /// Why this node type is critical
    var whyCritical: String {
        switch self {
        case .liZhang:       return "行政樞紐，掌握社區動態"
        case .farmersAssoc:  return "掌握資源流向"
        case .temple:        return "人情消息中心"
        case .opinionLeader: return "社會資本，說話有份量"
        case .factoryMaster: return "知道什麼被低估"
        case .repairTech:    return "第一手淘汰訊號"
        case .contractor:    return "剩料 / 閒置"
        }
    }

    /// SF Symbol icon name
    var iconName: String {
        switch self {
        case .liZhang:       return "person.badge.shield.checkmark"
        case .farmersAssoc:  return "leaf.fill"
        case .temple:        return "building.columns.fill"
        case .opinionLeader: return "star.fill"
        case .factoryMaster: return "wrench.and.screwdriver.fill"
        case .repairTech:    return "hammer.fill"
        case .contractor:    return "shippingbox.fill"
        }
    }

    /// Brand color for this node type
    var colorHex: String {
        switch self {
        case .liZhang:       return "#6366F1" // Indigo
        case .farmersAssoc:  return "#10B981" // Emerald
        case .temple:        return "#F59E0B" // Amber
        case .opinionLeader: return "#EC4899" // Pink (月老 theme)
        case .factoryMaster: return "#8B5CF6" // Violet
        case .repairTech:    return "#EF4444" // Red
        case .contractor:    return "#3B82F6" // Blue
        }
    }
}

import Foundation

/// Community tea party event.
struct CommunityEvent: Codable, Identifiable {
    let id: String
    let createdAt: String
    let updatedAt: String

    let hostNodePersonId: String
    let title: String
    let description: String?
    let location: String
    let latitude: Double?
    let longitude: Double?

    let scheduledAt: String
    let endAt: String?
    let maxCapacity: Int
    let status: String  // 'upcoming', 'active', 'completed', 'cancelled'
    let qrCode: String?

    /// Embedded host info (when included)
    let hostNodePerson: EventHost?

    /// Attendee count (from _count)
    struct CountWrapper: Codable {
        let attendees: Int?
    }
    let _count: CountWrapper?

    var attendeeCount: Int {
        _count?.attendees ?? 0
    }

    /// Display status
    var statusLabel: String {
        switch status {
        case "upcoming": return "即將舉行"
        case "active": return "進行中"
        case "completed": return "已完成"
        case "cancelled": return "已取消"
        default: return status
        }
    }

    var statusColor: String {
        switch status {
        case "upcoming": return "blue"
        case "active": return "green"
        case "completed": return "gray"
        case "cancelled": return "red"
        default: return "gray"
        }
    }
}

struct EventHost: Codable {
    let id: String
    let name: String
    let nodeType: String
    let district: String?
    let region: String?
}

struct EventAttendee: Codable, Identifiable {
    let id: String
    let createdAt: String
    let nodePersonId: String?
    let userId: String?
    let name: String?
    let phone: String?
    let checkedIn: Bool
    let checkedInAt: String?
}

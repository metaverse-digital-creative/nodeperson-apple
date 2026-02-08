import Foundation

/// A recorded wellness session.
struct WellnessSession: Codable, Identifiable {
    let id: String
    let canvas: WellnessCanvas
    let startedAt: Date
    var duration: TimeInterval
    var completedCycles: Int
    var isCompleted: Bool

    init(canvas: WellnessCanvas) {
        self.id = UUID().uuidString
        self.canvas = canvas
        self.startedAt = Date()
        self.duration = 0
        self.completedCycles = 0
        self.isCompleted = false
    }
}

/// Daily wellness progress snapshot.
struct WellnessDailyProgress: Codable {
    let date: String                   // "yyyy-MM-dd"
    var sessionsCompleted: Int
    var totalMinutes: Double
    var canvasesUsed: Set<String>       // raw values of WellnessCanvas

    var canvasCount: Int { canvasesUsed.count }

    static func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

/// Streak tracking data persisted via UserDefaults.
struct WellnessStreak: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var lastActiveDate: String          // "yyyy-MM-dd"
    var totalSessions: Int
    var totalMinutes: Double

    static let empty = WellnessStreak(
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDate: "",
        totalSessions: 0,
        totalMinutes: 0
    )
}

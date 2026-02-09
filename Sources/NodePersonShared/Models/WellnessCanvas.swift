import Foundation

/// The 5 wellness canvases — each targets a specific lifestyle dimension.
enum WellnessCanvas: String, CaseIterable, Identifiable, Codable {
    case flowState
    case betterSleep
    case comfortVision
    case athleticPerformance
    case metabolismRepair

    var id: String { rawValue }

    // MARK: - Display

    var title: String {
        switch self {
        case .flowState:            return "進入心流"
        case .betterSleep:          return "Better Sleep"
        case .comfortVision:        return "舒適使用"
        case .athleticPerformance:  return "運動提升"
        case .metabolismRepair:     return "代謝修復"
        }
    }

    var subtitle: String {
        switch self {
        case .flowState:            return "Flow State"
        case .betterSleep:          return "Sleep Quality"
        case .comfortVision:        return "Vision Pro Comfort"
        case .athleticPerformance:  return "Athletic Performance"
        case .metabolismRepair:     return "Metabolism & Self-Repair"
        }
    }

    var iconName: String {
        switch self {
        case .flowState:            return "brain.head.profile"
        case .betterSleep:          return "moon.zzz.fill"
        case .comfortVision:        return "eye.fill"
        case .athleticPerformance:  return "figure.run"
        case .metabolismRepair:     return "bolt.heart.fill"
        }
    }

    var accentColorHex: String {
        switch self {
        case .flowState:            return "#7C3AED"   // violet
        case .betterSleep:          return "#1E40AF"   // deep blue
        case .comfortVision:        return "#059669"   // emerald
        case .athleticPerformance:  return "#DC2626"   // red
        case .metabolismRepair:     return "#D97706"   // amber
        }
    }

    var gradientEndHex: String {
        switch self {
        case .flowState:            return "#4F46E5"
        case .betterSleep:          return "#1E3A8A"
        case .comfortVision:        return "#047857"
        case .athleticPerformance:  return "#991B1B"
        case .metabolismRepair:     return "#B45309"
        }
    }

    var description: String {
        switch self {
        case .flowState:
            return "透過引導式呼吸與專注計時，幫助你快速進入心流狀態，提升工作與創作效率。"
        case .betterSleep:
            return "睡前放鬆呼吸法、環境優化建議，讓你擁有更深層的睡眠品質。"
        case .comfortVision:
            return "定時護眼運動、頸部伸展、姿勢提醒，讓你長時間使用 Vision Pro 也不會不舒服。"
        case .athleticPerformance:
            return "運動前暖身呼吸、跑步節奏呼吸、間歇計時，全面提升你的運動表現。"
        case .metabolismRepair:
            return "提升整體代謝與身體自我修復，達成更好的體態、更飽滿的臉龐、更少的紋路、促進膠原蛋白自我生成。"
        }
    }

    var benefits: [String] {
        switch self {
        case .flowState:
            return [
                "更快速進入深度專注",
                "減少分心與思緒漫遊",
                "提升創作與工作產出",
                "建立穩定的專注習慣",
            ]
        case .betterSleep:
            return [
                "入睡時間縮短",
                "深層睡眠比例提升",
                "起床後精神飽滿",
                "減少半夜醒來次數",
            ]
        case .comfortVision:
            return [
                "眼睛不會酸澀",
                "脖子不會僵硬",
                "長時間使用更舒適",
                "預防姿勢不良",
            ]
        case .athleticPerformance:
            return [
                "跑步耐力提升",
                "運動時呼吸更順暢",
                "恢復速度加快",
                "整體運動表現提升",
            ]
        case .metabolismRepair:
            return [
                "整體代謝提升",
                "身體自我修復加速",
                "體態更好 Better Shape",
                "臉龐更飽滿有光澤",
                "紋路逐漸變淺",
                "膠原蛋白自我產生",
            ]
        }
    }

    /// Default breathing pattern for each canvas
    var defaultBreathingPattern: BreathingPattern {
        switch self {
        case .flowState:            return .boxBreathing
        case .betterSleep:          return .sleepBreathing478
        case .comfortVision:        return .relaxedBreathing
        case .athleticPerformance:  return .runningCadence
        case .metabolismRepair:     return .wimHof
        }
    }

    /// Default session duration in seconds
    var defaultDurationSeconds: Int {
        switch self {
        case .flowState:            return 25 * 60  // 25 min
        case .betterSleep:          return 10 * 60  // 10 min
        case .comfortVision:        return 5 * 60   // 5 min (eye break)
        case .athleticPerformance:  return 3 * 60   // 3 min warm-up
        case .metabolismRepair:     return 15 * 60  // 15 min
        }
    }
}

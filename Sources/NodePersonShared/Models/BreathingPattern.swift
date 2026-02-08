import Foundation

/// A breathing technique with timed phases.
struct BreathingPattern: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let nameZH: String
    let inhaleSeconds: Double
    let holdSeconds: Double
    let exhaleSeconds: Double
    let holdAfterExhaleSeconds: Double
    let cycles: Int
    let description: String

    /// Total duration of one cycle
    var cycleDuration: Double {
        inhaleSeconds + holdSeconds + exhaleSeconds + holdAfterExhaleSeconds
    }

    /// Total duration for all cycles
    var totalDuration: Double {
        cycleDuration * Double(cycles)
    }
}

// MARK: - Preset Patterns

extension BreathingPattern {
    /// Box Breathing (4-4-4-4) — Navy SEALs technique for focus
    static let boxBreathing = BreathingPattern(
        id: "box",
        name: "Box Breathing",
        nameZH: "方塊呼吸法",
        inhaleSeconds: 4,
        holdSeconds: 4,
        exhaleSeconds: 4,
        holdAfterExhaleSeconds: 4,
        cycles: 8,
        description: "Equal phase breathing for deep focus and calm."
    )

    /// 4-7-8 Breathing — Dr. Andrew Weil's sleep technique
    static let sleepBreathing478 = BreathingPattern(
        id: "sleep478",
        name: "4-7-8 Sleep Breathing",
        nameZH: "4-7-8 助眠呼吸法",
        inhaleSeconds: 4,
        holdSeconds: 7,
        exhaleSeconds: 8,
        holdAfterExhaleSeconds: 0,
        cycles: 6,
        description: "Extended exhale activates parasympathetic nervous system for sleep."
    )

    /// Relaxed Breathing — gentle, for eye breaks & comfort
    static let relaxedBreathing = BreathingPattern(
        id: "relaxed",
        name: "Relaxed Breathing",
        nameZH: "放鬆呼吸",
        inhaleSeconds: 4,
        holdSeconds: 2,
        exhaleSeconds: 6,
        holdAfterExhaleSeconds: 0,
        cycles: 10,
        description: "Long exhale for relaxation and eye relief."
    )

    /// Running Cadence Breathing — syncs with footstrike
    static let runningCadence = BreathingPattern(
        id: "running",
        name: "Running Cadence",
        nameZH: "跑步節奏呼吸",
        inhaleSeconds: 3,
        holdSeconds: 0,
        exhaleSeconds: 2,
        holdAfterExhaleSeconds: 0,
        cycles: 20,
        description: "3-step inhale, 2-step exhale for sustained running."
    )

    /// Wim Hof style — power breathing for metabolism
    static let wimHof = BreathingPattern(
        id: "wimhof",
        name: "Power Breathing",
        nameZH: "力量呼吸法",
        inhaleSeconds: 2,
        holdSeconds: 0,
        exhaleSeconds: 2,
        holdAfterExhaleSeconds: 0,
        cycles: 30,
        description: "Rapid deep breathing to boost metabolism and recovery."
    )

    /// All available patterns
    static let allPatterns: [BreathingPattern] = [
        .boxBreathing,
        .sleepBreathing478,
        .relaxedBreathing,
        .runningCadence,
        .wimHof,
    ]
}

/// Phase of a breathing cycle
enum BreathingPhase: String, CaseIterable {
    case inhale
    case holdAfterInhale
    case exhale
    case holdAfterExhale

    var label: String {
        switch self {
        case .inhale:           return "吸氣"
        case .holdAfterInhale:  return "屏息"
        case .exhale:           return "吐氣"
        case .holdAfterExhale:  return "靜止"
        }
    }

    var englishLabel: String {
        switch self {
        case .inhale:           return "Inhale"
        case .holdAfterInhale:  return "Hold"
        case .exhale:           return "Exhale"
        case .holdAfterExhale:  return "Rest"
        }
    }

    /// Duration for this phase given a breathing pattern
    func duration(for pattern: BreathingPattern) -> Double {
        switch self {
        case .inhale:           return pattern.inhaleSeconds
        case .holdAfterInhale:  return pattern.holdSeconds
        case .exhale:           return pattern.exhaleSeconds
        case .holdAfterExhale:  return pattern.holdAfterExhaleSeconds
        }
    }
}

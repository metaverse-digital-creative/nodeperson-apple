import Foundation
import SwiftUI
import Combine

/// Shared view model for wellness sessions — breathing timer, streaks, session tracking.
@Observable
final class WellnessViewModel {

    // MARK: - Published State

    var selectedCanvas: WellnessCanvas = .flowState
    var currentPattern: BreathingPattern = .boxBreathing
    var currentPhase: BreathingPhase = .inhale
    var phaseProgress: Double = 0          // 0…1 within current phase
    var overallProgress: Double = 0        // 0…1 for entire session
    var currentCycle: Int = 0
    var isSessionActive: Bool = false
    var isPaused: Bool = false
    var elapsedSeconds: TimeInterval = 0
    var streak: WellnessStreak = .empty
    var dailyProgress: WellnessDailyProgress?

    // Scale factor for the breathing circle (0.5…1.0)
    var breathingScale: Double = 0.5

    // MARK: - Private

    private var timer: Timer?
    private var tickInterval: TimeInterval = 0.05   // 20 fps animation
    private var phaseElapsed: Double = 0
    private var currentSession: WellnessSession?

    // MARK: - Lifecycle

    init() {
        loadStreak()
        loadDailyProgress()
    }

    // MARK: - Canvas Selection

    func selectCanvas(_ canvas: WellnessCanvas) {
        selectedCanvas = canvas
        currentPattern = canvas.defaultBreathingPattern
        resetSession()
    }

    // MARK: - Session Control

    func startSession() {
        guard !isSessionActive else { return }
        currentSession = WellnessSession(canvas: selectedCanvas)
        isSessionActive = true
        isPaused = false
        currentCycle = 1
        currentPhase = .inhale
        phaseElapsed = 0
        elapsedSeconds = 0
        overallProgress = 0
        phaseProgress = 0
        breathingScale = 0.5
        startTimer()
    }

    func pauseSession() {
        isPaused = true
        timer?.invalidate()
        timer = nil
    }

    func resumeSession() {
        guard isPaused else { return }
        isPaused = false
        startTimer()
    }

    func stopSession() {
        timer?.invalidate()
        timer = nil

        if var session = currentSession {
            session.duration = elapsedSeconds
            session.completedCycles = max(0, currentCycle - 1)
            session.isCompleted = currentCycle > currentPattern.cycles
            recordSession(session)
        }

        isSessionActive = false
        isPaused = false
        currentSession = nil
        resetSession()
    }

    func toggleSession() {
        if !isSessionActive {
            startSession()
        } else if isPaused {
            resumeSession()
        } else {
            pauseSession()
        }
    }

    // MARK: - Timer

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard isSessionActive, !isPaused else { return }

        phaseElapsed += tickInterval
        elapsedSeconds += tickInterval

        let phaseDuration = currentPhase.duration(for: currentPattern)

        // Skip zero-duration phases
        if phaseDuration <= 0 {
            advancePhase()
            return
        }

        phaseProgress = min(phaseElapsed / phaseDuration, 1.0)

        // Animate breathing scale
        updateBreathingScale()

        // Calculate overall progress
        let totalDuration = currentPattern.totalDuration
        if totalDuration > 0 {
            let cycleOffset = Double(currentCycle - 1) * currentPattern.cycleDuration
            let phaseOffset = phasesOffset(upTo: currentPhase, in: currentPattern)
            let sessionElapsed = cycleOffset + phaseOffset + phaseElapsed
            overallProgress = min(sessionElapsed / totalDuration, 1.0)
        }

        // Phase complete?
        if phaseElapsed >= phaseDuration {
            advancePhase()
        }
    }

    private func advancePhase() {
        phaseElapsed = 0
        phaseProgress = 0

        switch currentPhase {
        case .inhale:
            currentPhase = currentPattern.holdSeconds > 0 ? .holdAfterInhale : .exhale
        case .holdAfterInhale:
            currentPhase = .exhale
        case .exhale:
            if currentPattern.holdAfterExhaleSeconds > 0 {
                currentPhase = .holdAfterExhale
            } else {
                completeCycle()
            }
        case .holdAfterExhale:
            completeCycle()
        }
    }

    private func completeCycle() {
        currentCycle += 1
        currentPhase = .inhale

        if currentCycle > currentPattern.cycles {
            // Session complete
            stopSession()
        }
    }

    private func updateBreathingScale() {
        switch currentPhase {
        case .inhale:
            // Scale up 0.5 → 1.0
            breathingScale = 0.5 + 0.5 * phaseProgress
        case .holdAfterInhale:
            breathingScale = 1.0
        case .exhale:
            // Scale down 1.0 → 0.5
            breathingScale = 1.0 - 0.5 * phaseProgress
        case .holdAfterExhale:
            breathingScale = 0.5
        }
    }

    private func phasesOffset(upTo phase: BreathingPhase, in pattern: BreathingPattern) -> Double {
        var offset: Double = 0
        for p in BreathingPhase.allCases {
            if p == phase { break }
            offset += p.duration(for: pattern)
        }
        return offset
    }

    private func resetSession() {
        currentPhase = .inhale
        phaseProgress = 0
        overallProgress = 0
        currentCycle = 0
        elapsedSeconds = 0
        breathingScale = 0.5
    }

    // MARK: - Formatted Time

    var elapsedFormatted: String {
        let mins = Int(elapsedSeconds) / 60
        let secs = Int(elapsedSeconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    var phaseDurationFormatted: String {
        let duration = currentPhase.duration(for: currentPattern)
        return String(format: "%.0f s", duration)
    }

    var cycleLabel: String {
        "\(min(currentCycle, currentPattern.cycles))/\(currentPattern.cycles)"
    }

    // MARK: - Persistence (UserDefaults)

    private let streakKey = "wellness_streak"
    private let dailyKey = "wellness_daily"

    private func loadStreak() {
        guard let data = UserDefaults.standard.data(forKey: streakKey),
              let saved = try? JSONDecoder().decode(WellnessStreak.self, from: data) else { return }
        streak = saved
    }

    private func saveStreak() {
        if let data = try? JSONEncoder().encode(streak) {
            UserDefaults.standard.set(data, forKey: streakKey)
        }
    }

    private func loadDailyProgress() {
        guard let data = UserDefaults.standard.data(forKey: dailyKey),
              let saved = try? JSONDecoder().decode(WellnessDailyProgress.self, from: data),
              saved.date == WellnessDailyProgress.todayKey() else {
            dailyProgress = WellnessDailyProgress(
                date: WellnessDailyProgress.todayKey(),
                sessionsCompleted: 0,
                totalMinutes: 0,
                canvasesUsed: []
            )
            return
        }
        dailyProgress = saved
    }

    private func saveDailyProgress() {
        if let data = try? JSONEncoder().encode(dailyProgress) {
            UserDefaults.standard.set(data, forKey: dailyKey)
        }
    }

    private func recordSession(_ session: WellnessSession) {
        let minutes = session.duration / 60.0

        // Update daily
        dailyProgress?.sessionsCompleted += 1
        dailyProgress?.totalMinutes += minutes
        dailyProgress?.canvasesUsed.insert(session.canvas.rawValue)
        saveDailyProgress()

        // Update streak
        let today = WellnessDailyProgress.todayKey()
        if streak.lastActiveDate == today {
            // Same day, just update totals
        } else {
            // Check if yesterday — continue streak
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let lastDate = formatter.date(from: streak.lastActiveDate) {
                let calendar = Calendar.current
                if calendar.isDate(lastDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: Date())!) {
                    streak.currentStreak += 1
                } else {
                    streak.currentStreak = 1
                }
            } else {
                streak.currentStreak = 1
            }
        }
        streak.lastActiveDate = today
        streak.longestStreak = max(streak.longestStreak, streak.currentStreak)
        streak.totalSessions += 1
        streak.totalMinutes += minutes
        saveStreak()
    }
}

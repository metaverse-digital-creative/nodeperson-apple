import SwiftUI
import NodePersonShared

/// Canvas 4 — Athletic Performance
/// Pre-workout breathing, running cadence, interval timer, recovery.
struct AthleticPerformanceCanvasView: View {
    @State private var viewModel = WellnessViewModel()
    @State private var selectedMode: WorkoutMode = .warmUp
    @State private var intervalWork: Int = 30     // seconds
    @State private var intervalRest: Int = 15     // seconds
    @State private var intervalRounds: Int = 8
    private let canvas = WellnessCanvas.athleticPerformance

    enum WorkoutMode: String, CaseIterable, Identifiable {
        case warmUp = "暖身"
        case running = "跑步"
        case interval = "間歇"
        case recovery = "恢復"
        var id: String { rawValue }

        var icon: String {
            switch self {
            case .warmUp:   return "flame.fill"
            case .running:  return "figure.run"
            case .interval: return "timer"
            case .recovery: return "leaf.fill"
            }
        }

        var breathingPattern: BreathingPattern {
            switch self {
            case .warmUp:   return .boxBreathing
            case .running:  return .runningCadence
            case .interval: return .boxBreathing
            case .recovery: return .relaxedBreathing
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Breathing circle
                BreathingCircleView(
                    pattern: viewModel.currentPattern,
                    phase: viewModel.currentPhase,
                    progress: viewModel.phaseProgress,
                    scale: viewModel.breathingScale,
                    accentHex: canvas.accentColorHex,
                    gradientEndHex: canvas.gradientEndHex
                )
                .frame(height: 260)
                .padding(.top, 12)

                // Timer
                VStack(spacing: 6) {
                    Text(viewModel.elapsedFormatted)
                        .font(.system(size: 44, weight: .light, design: .rounded))
                        .monospacedDigit()
                    Text("Cycle \(viewModel.cycleLabel)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Workout mode selector
                HStack(spacing: 8) {
                    ForEach(WorkoutMode.allCases) { mode in
                        Button {
                            selectedMode = mode
                            viewModel.currentPattern = mode.breathingPattern
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: mode.icon)
                                    .font(.title3)
                                Text(mode.rawValue)
                                    .font(.caption2.bold())
                            }
                            .foregroundStyle(selectedMode == mode ? .white : Color(hex: canvas.accentColorHex))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedMode == mode
                                    ? Color(hex: canvas.accentColorHex)
                                    : Color(hex: canvas.accentColorHex).opacity(0.1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal)

                // Start/control
                Button {
                    if !viewModel.isSessionActive {
                        viewModel.selectCanvas(canvas)
                        viewModel.currentPattern = selectedMode.breathingPattern
                        viewModel.startSession()
                    } else {
                        viewModel.toggleSession()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.isSessionActive ?
                              (viewModel.isPaused ? "play.fill" : "pause.fill") : "play.fill")
                        Text(viewModel.isSessionActive ?
                             (viewModel.isPaused ? "繼續" : "暫停") : "開始 \(selectedMode.rawValue)")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: canvas.accentColorHex))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)

                if viewModel.isSessionActive {
                    Button { viewModel.stopSession() } label: {
                        Text("結束練習")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // Running tips
                if selectedMode == .running {
                    runningTipsCard
                }

                // Interval config (not during session)
                if selectedMode == .interval && !viewModel.isSessionActive {
                    intervalConfigCard
                }

                // Breathing pattern info
                patternCard

                // Benefits
                benefitsCard
            }
            .padding(.bottom, 40)
        }
        .navigationTitle(canvas.title)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.selectCanvas(canvas)
        }
    }

    private var runningTipsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "figure.run")
                    .foregroundStyle(Color(hex: canvas.accentColorHex))
                Text("跑步呼吸技巧")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                tipRow("吸氣 3 步", "配合腳步節奏，鼻子吸氣踩 3 步")
                tipRow("吐氣 2 步", "嘴巴吐氣踩 2 步，保持穩定節奏")
                tipRow("保持放鬆", "肩膀放鬆下垂，不要聳肩")
                tipRow("逐漸加長", "習慣後可嘗試 4:3 或 5:4 的節奏")
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func tipRow(_ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "chevron.right.circle.fill")
                .foregroundStyle(Color(hex: canvas.accentColorHex))
                .font(.caption)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var intervalConfigCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⏱️ 間歇設定")
                .font(.headline)

            HStack {
                Text("運動秒數")
                    .font(.subheadline)
                Spacer()
                Stepper("\(intervalWork)s", value: $intervalWork, in: 10...120, step: 5)
                    .font(.subheadline.bold())
            }
            HStack {
                Text("休息秒數")
                    .font(.subheadline)
                Spacer()
                Stepper("\(intervalRest)s", value: $intervalRest, in: 5...60, step: 5)
                    .font(.subheadline.bold())
            }
            HStack {
                Text("組數")
                    .font(.subheadline)
                Spacer()
                Stepper("\(intervalRounds)", value: $intervalRounds, in: 3...20)
                    .font(.subheadline.bold())
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var patternCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "wind")
                    .foregroundStyle(Color(hex: canvas.accentColorHex))
                Text(viewModel.currentPattern.nameZH)
                    .font(.headline)
            }
            Text(viewModel.currentPattern.description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var benefitsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("持續練習的好處")
                .font(.headline)
            ForEach(canvas.benefits, id: \.self) { benefit in
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color(hex: canvas.accentColorHex))
                        .font(.caption)
                    Text(benefit)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

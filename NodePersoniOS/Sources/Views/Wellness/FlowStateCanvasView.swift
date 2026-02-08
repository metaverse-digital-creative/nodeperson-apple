import SwiftUI
import NodePersonShared

/// Canvas 1 — 進入心流 (Flow State)
/// Guided breathing + focus timer for deep work sessions.
struct FlowStateCanvasView: View {
    @State private var viewModel = WellnessViewModel()
    @State private var focusDuration: Int = 25  // minutes
    private let canvas = WellnessCanvas.flowState

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Breathing circle
                BreathingCircleView(
                    pattern: viewModel.currentPattern,
                    phase: viewModel.currentPhase,
                    progress: viewModel.phaseProgress,
                    scale: viewModel.breathingScale,
                    accentHex: canvas.accentColorHex,
                    gradientEndHex: canvas.gradientEndHex
                )
                .frame(height: 280)
                .padding(.top, 20)

                // Session info
                VStack(spacing: 8) {
                    Text(viewModel.elapsedFormatted)
                        .font(.system(size: 48, weight: .light, design: .rounded))
                        .monospacedDigit()

                    Text("Cycle \(viewModel.cycleLabel)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Control button
                Button {
                    if !viewModel.isSessionActive {
                        viewModel.selectCanvas(canvas)
                        viewModel.startSession()
                    } else {
                        viewModel.toggleSession()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: controlIcon)
                        Text(controlLabel)
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
                    Button {
                        viewModel.stopSession()
                    } label: {
                        Text("結束練習")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // Focus duration picker (only when not active)
                if !viewModel.isSessionActive {
                    VStack(spacing: 12) {
                        Text("專注時長")
                            .font(.headline)

                        HStack(spacing: 12) {
                            ForEach([25, 45, 90], id: \.self) { mins in
                                Button {
                                    focusDuration = mins
                                } label: {
                                    Text("\(mins) 分鐘")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(focusDuration == mins ? .white : Color(hex: canvas.accentColorHex))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            focusDuration == mins
                                                ? Color(hex: canvas.accentColorHex)
                                                : Color(hex: canvas.accentColorHex).opacity(0.1)
                                        )
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                }

                // Breathing pattern info
                patternInfoCard

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

    private var controlIcon: String {
        if !viewModel.isSessionActive { return "play.fill" }
        return viewModel.isPaused ? "play.fill" : "pause.fill"
    }

    private var controlLabel: String {
        if !viewModel.isSessionActive { return "開始心流" }
        return viewModel.isPaused ? "繼續" : "暫停"
    }

    private var patternInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "wind")
                    .foregroundStyle(Color(hex: canvas.accentColorHex))
                Text(viewModel.currentPattern.nameZH)
                    .font(.headline)
            }
            Text(viewModel.currentPattern.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                phaseTag("吸", "\(Int(viewModel.currentPattern.inhaleSeconds))s")
                if viewModel.currentPattern.holdSeconds > 0 {
                    phaseTag("屏", "\(Int(viewModel.currentPattern.holdSeconds))s")
                }
                phaseTag("吐", "\(Int(viewModel.currentPattern.exhaleSeconds))s")
                if viewModel.currentPattern.holdAfterExhaleSeconds > 0 {
                    phaseTag("靜", "\(Int(viewModel.currentPattern.holdAfterExhaleSeconds))s")
                }
            }
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

    private func phaseTag(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.bold())
                .foregroundStyle(Color(hex: canvas.accentColorHex))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(hex: canvas.accentColorHex).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

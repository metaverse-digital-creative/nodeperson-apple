import SwiftUI
import NodePersonShared

/// watchOS wellness companion — breathing with haptics, canvas picker, timer.
struct WatchWellnessView: View {
    @State private var viewModel = WellnessViewModel()
    @State private var selectedCanvas: WellnessCanvas = .flowState

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Canvas picker
                ForEach(WellnessCanvas.allCases) { canvas in
                    Button {
                        selectedCanvas = canvas
                        viewModel.selectCanvas(canvas)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: canvas.iconName)
                                .font(.body)
                                .foregroundStyle(Color(hex: canvas.accentColorHex))
                                .frame(width: 32, height: 32)
                                .background(Color(hex: canvas.accentColorHex).opacity(0.2))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(canvas.title)
                                    .font(.caption.bold())
                                    .foregroundStyle(selectedCanvas == canvas ? Color(hex: canvas.accentColorHex) : .primary)
                                Text(canvas.subtitle)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if selectedCanvas == canvas {
                                Image(systemName: "checkmark")
                                    .font(.caption2.bold())
                                    .foregroundStyle(Color(hex: canvas.accentColorHex))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                Divider()

                // Breathing guide
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: selectedCanvas.accentColorHex).opacity(0.8),
                                    Color(hex: selectedCanvas.gradientEndHex).opacity(0.3),
                                ],
                                center: .center,
                                startRadius: 5,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(viewModel.breathingScale)

                    VStack(spacing: 2) {
                        Text(viewModel.currentPhase.label)
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                        Text(viewModel.currentPhase.englishLabel)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: viewModel.breathingScale)

                // Timer
                Text(viewModel.elapsedFormatted)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .monospacedDigit()

                // Control button
                Button {
                    if !viewModel.isSessionActive {
                        viewModel.selectCanvas(selectedCanvas)
                        viewModel.startSession()
                    } else {
                        viewModel.toggleSession()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: viewModel.isSessionActive ?
                              (viewModel.isPaused ? "play.fill" : "pause.fill") : "play.fill")
                        Text(viewModel.isSessionActive ?
                             (viewModel.isPaused ? "繼續" : "暫停") : "開始")
                    }
                    .font(.caption.bold())
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: selectedCanvas.accentColorHex))

                if viewModel.isSessionActive {
                    Button {
                        viewModel.stopSession()
                    } label: {
                        Text("結束")
                            .font(.caption2)
                    }
                    .buttonStyle(.bordered)
                }

                // Streak
                if viewModel.streak.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text("\(viewModel.streak.currentStreak) 天")
                            .font(.caption2.bold())
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Wellness")
    }
}

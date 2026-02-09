import SwiftUI
import NodePersonShared

/// visionOS spatial wellness dashboard with glass-material canvas cards.
struct VisionWellnessHomeView: View {
    @State private var viewModel = WellnessViewModel()
    @State private var selectedCanvas: WellnessCanvas?

    var body: some View {
        NavigationSplitView {
            List(WellnessCanvas.allCases, selection: $selectedCanvas) { canvas in
                NavigationLink(value: canvas) {
                    HStack(spacing: 16) {
                        Image(systemName: canvas.iconName)
                            .font(.title2)
                            .foregroundStyle(Color(hex: canvas.accentColorHex))
                            .frame(width: 48, height: 48)
                            .background(Color(hex: canvas.accentColorHex).opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(canvas.title)
                                .font(.headline)
                            Text(canvas.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Wellness")
        } detail: {
            if let canvas = selectedCanvas {
                VisionCanvasDetailView(canvas: canvas, viewModel: viewModel)
            } else {
                // Welcome
                VStack(spacing: 24) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#7C3AED"), Color(hex: "#EC4899")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Wellness Focus")
                        .font(.largeTitle.bold())

                    Text("選擇一個畫布開始你的專注練習")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    // Quick stats
                    if viewModel.streak.currentStreak > 0 {
                        HStack(spacing: 20) {
                            statPill("🔥", "\(viewModel.streak.currentStreak)", "天連續")
                            statPill("🧘", "\(viewModel.streak.totalSessions)", "次練習")
                            statPill("⏱️", String(format: "%.0f", viewModel.streak.totalMinutes), "分鐘")
                        }
                    }

                    // Canvas cards in a row
                    HStack(spacing: 16) {
                        ForEach(WellnessCanvas.allCases) { canvas in
                            Button {
                                selectedCanvas = canvas
                            } label: {
                                VStack(spacing: 12) {
                                    Image(systemName: canvas.iconName)
                                        .font(.title)
                                        .foregroundStyle(Color(hex: canvas.accentColorHex))

                                    Text(canvas.title)
                                        .font(.subheadline.bold())

                                    Text(canvas.subtitle)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(width: 140, height: 130)
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func statPill(_ emoji: String, _ value: String, _ label: String) -> some View {
        HStack(spacing: 6) {
            Text(emoji)
            Text(value)
                .font(.headline.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.regularMaterial)
        .clipShape(Capsule())
    }
}

// MARK: - Vision Canvas Detail

struct VisionCanvasDetailView: View {
    let canvas: WellnessCanvas
    @Bindable var viewModel: WellnessViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Large breathing sphere
                VisionBreathingView(
                    viewModel: viewModel,
                    canvas: canvas
                )
                .frame(height: 320)

                // Timer + controls
                VStack(spacing: 12) {
                    Text(viewModel.elapsedFormatted)
                        .font(.system(size: 56, weight: .ultraLight, design: .rounded))
                        .monospacedDigit()

                    Text("Cycle \(viewModel.cycleLabel)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Controls
                HStack(spacing: 16) {
                    Button {
                        if !viewModel.isSessionActive {
                            viewModel.selectCanvas(canvas)
                            viewModel.startSession()
                        } else {
                            viewModel.toggleSession()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: viewModel.isSessionActive ?
                                  (viewModel.isPaused ? "play.fill" : "pause.fill") : "play.fill")
                            Text(viewModel.isSessionActive ?
                                 (viewModel.isPaused ? "Resume" : "Pause") : "Start")
                        }
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color(hex: canvas.accentColorHex))
                        .clipShape(Capsule())
                    }

                    if viewModel.isSessionActive {
                        Button {
                            viewModel.stopSession()
                        } label: {
                            Image(systemName: "stop.fill")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .padding(16)
                                .background(.regularMaterial)
                                .clipShape(Circle())
                        }
                    }
                }

                // Canvas description
                VStack(alignment: .leading, spacing: 16) {
                    Text(canvas.description)
                        .font(.body)
                        .foregroundStyle(.secondary)

                    // Benefits
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Benefits")
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
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 32)
            }
            .padding(32)
        }
        .navigationTitle(canvas.title)
        .onAppear {
            viewModel.selectCanvas(canvas)
        }
    }
}

// MARK: - Vision Breathing Sphere

struct VisionBreathingView: View {
    @Bindable var viewModel: WellnessViewModel
    let canvas: WellnessCanvas

    var body: some View {
        ZStack {
            // Outer glow layers for depth
            Circle()
                .fill(Color(hex: canvas.accentColorHex).opacity(0.05))
                .frame(width: 300, height: 300)
                .scaleEffect(viewModel.breathingScale * 1.2)

            Circle()
                .fill(Color(hex: canvas.accentColorHex).opacity(0.1))
                .frame(width: 260, height: 260)
                .scaleEffect(viewModel.breathingScale * 1.1)

            // Main sphere
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: canvas.accentColorHex).opacity(0.9),
                            Color(hex: canvas.gradientEndHex).opacity(0.5),
                            Color(hex: canvas.accentColorHex).opacity(0.15),
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .scaleEffect(viewModel.breathingScale)
                .shadow(color: Color(hex: canvas.accentColorHex).opacity(0.5), radius: 40)

            // Phase label
            VStack(spacing: 8) {
                Text(viewModel.currentPhase.label)
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(viewModel.currentPhase.englishLabel)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .animation(.easeInOut(duration: 0.15), value: viewModel.breathingScale)
    }
}

import SwiftUI
import NodePersonShared

/// Canvas 3 — Comfortable Vision Pro Usage
/// 20-20-20 eye exercises, neck stretches, posture reminders.
struct ComfortVisionCanvasView: View {
    @State private var viewModel = WellnessViewModel()
    @State private var eyeTimerActive = false
    @State private var eyeTimerSeconds: Int = 0
    @State private var eyeTimer: Timer?
    @State private var currentExercise: Int = 0
    private let canvas = WellnessCanvas.comfortVision

    private let eyeExercises: [EyeExercise] = [
        EyeExercise(
            title: "20-20-20 遠望",
            instruction: "看向 20 英尺（6 公尺）遠的物體，持續 20 秒",
            icon: "eye",
            durationSeconds: 20
        ),
        EyeExercise(
            title: "眼球環繞",
            instruction: "慢慢地將眼球順時針轉一圈，再逆時針轉一圈",
            icon: "arrow.clockwise",
            durationSeconds: 15
        ),
        EyeExercise(
            title: "近遠交替對焦",
            instruction: "注視近處手指 5 秒，再看遠處 5 秒，交替 3 次",
            icon: "arrow.up.and.down",
            durationSeconds: 30
        ),
        EyeExercise(
            title: "溫敷眼部",
            instruction: "用手掌搓熱後輕蓋在閉合的眼睛上",
            icon: "hand.raised.fill",
            durationSeconds: 20
        ),
    ]

    private let neckStretches: [NeckStretch] = [
        NeckStretch(title: "頭部左右傾斜", instruction: "將頭慢慢傾向左肩，停留 15 秒，再換右側", icon: "arrow.left.and.right"),
        NeckStretch(title: "下巴收縮", instruction: "下巴收向頸部，感覺後頸伸展，停留 10 秒", icon: "arrow.down.to.line"),
        NeckStretch(title: "肩膀旋轉", instruction: "雙肩向後大幅旋轉 10 圈", icon: "arrow.clockwise.circle"),
        NeckStretch(title: "頸部左右轉", instruction: "慢慢轉頭看向左方，停留 10 秒，再看右方", icon: "arrow.triangle.2.circlepath"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Breathing section (for relaxation during break)
                BreathingCircleView(
                    pattern: viewModel.currentPattern,
                    phase: viewModel.currentPhase,
                    progress: viewModel.phaseProgress,
                    scale: viewModel.breathingScale,
                    accentHex: canvas.accentColorHex,
                    gradientEndHex: canvas.gradientEndHex
                )
                .frame(height: 240)
                .padding(.top, 12)

                // 20-20-20 Timer
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundStyle(Color(hex: canvas.accentColorHex))
                        Text("20-20-20 護眼計時")
                            .font(.title3.bold())
                        Spacer()
                        if eyeTimerActive {
                            Text("\(eyeTimerSeconds / 60):\(String(format: "%02d", eyeTimerSeconds % 60))")
                                .font(.headline.monospacedDigit())
                                .foregroundStyle(Color(hex: canvas.accentColorHex))
                        }
                    }

                    Text("每使用 20 分鐘，看向遠處 20 秒，保護你的眼睛")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button {
                        if eyeTimerActive {
                            stopEyeTimer()
                        } else {
                            startEyeTimer()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: eyeTimerActive ? "stop.fill" : "play.fill")
                            Text(eyeTimerActive ? "停止計時" : "開始 20 分鐘計時")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: canvas.accentColorHex))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    // Progress bar
                    if eyeTimerActive {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(height: 8)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(hex: canvas.accentColorHex))
                                    .frame(
                                        width: geo.size.width * min(Double(eyeTimerSeconds) / (20.0 * 60.0), 1.0),
                                        height: 8
                                    )
                            }
                        }
                        .frame(height: 8)
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Eye exercises
                VStack(alignment: .leading, spacing: 16) {
                    Text("👁️ 護眼運動")
                        .font(.title3.bold())
                        .padding(.horizontal)

                    ForEach(eyeExercises.indices, id: \.self) { i in
                        let ex = eyeExercises[i]
                        HStack(spacing: 14) {
                            Image(systemName: ex.icon)
                                .font(.title2)
                                .foregroundStyle(Color(hex: canvas.accentColorHex))
                                .frame(width: 44, height: 44)
                                .background(Color(hex: canvas.accentColorHex).opacity(0.1))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(ex.title)
                                    .font(.subheadline.bold())
                                Text(ex.instruction)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("\(ex.durationSeconds)s")
                                .font(.caption.bold())
                                .foregroundStyle(Color(hex: canvas.accentColorHex))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: canvas.accentColorHex).opacity(0.1))
                                .clipShape(Capsule())
                        }
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal)
                    }
                }

                // Neck stretches
                VStack(alignment: .leading, spacing: 16) {
                    Text("🧘 頸部伸展")
                        .font(.title3.bold())
                        .padding(.horizontal)

                    ForEach(neckStretches.indices, id: \.self) { i in
                        let stretch = neckStretches[i]
                        HStack(spacing: 14) {
                            Image(systemName: stretch.icon)
                                .font(.title3)
                                .foregroundStyle(Color(hex: canvas.accentColorHex))
                                .frame(width: 40, height: 40)
                                .background(Color(hex: canvas.accentColorHex).opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(stretch.title)
                                    .font(.subheadline.bold())
                                Text(stretch.instruction)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal)
                    }
                }

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
        .onDisappear {
            stopEyeTimer()
        }
    }

    // MARK: - Eye Timer

    private func startEyeTimer() {
        eyeTimerSeconds = 0
        eyeTimerActive = true
        eyeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            eyeTimerSeconds += 1
        }
    }

    private func stopEyeTimer() {
        eyeTimerActive = false
        eyeTimer?.invalidate()
        eyeTimer = nil
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

// MARK: - Data Models

struct EyeExercise {
    let title: String
    let instruction: String
    let icon: String
    let durationSeconds: Int
}

struct NeckStretch {
    let title: String
    let instruction: String
    let icon: String
}

import SwiftUI
import NodePersonShared

/// Canvas 2 — Better Sleep Quality
/// Wind-down breathing, sleep checklist, bedtime routine.
struct SleepQualityCanvasView: View {
    @State private var viewModel = WellnessViewModel()
    @State private var checklist: [SleepCheckItem] = SleepCheckItem.defaults
    private let canvas = WellnessCanvas.betterSleep

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Night sky breathing circle
                ZStack {
                    // Starfield background
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#0F172A"),
                                    Color(hex: canvas.accentColorHex).opacity(0.3),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 340)
                        .overlay {
                            // Decorative stars
                            ForEach(0..<12, id: \.self) { i in
                                Circle()
                                    .fill(.white.opacity(Double.random(in: 0.2...0.6)))
                                    .frame(width: CGFloat.random(in: 2...4))
                                    .offset(
                                        x: CGFloat.random(in: -140...140),
                                        y: CGFloat.random(in: -140...140)
                                    )
                            }
                        }

                    BreathingCircleView(
                        pattern: viewModel.currentPattern,
                        phase: viewModel.currentPhase,
                        progress: viewModel.phaseProgress,
                        scale: viewModel.breathingScale,
                        accentHex: canvas.accentColorHex,
                        gradientEndHex: canvas.gradientEndHex
                    )
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Timer display
                VStack(spacing: 8) {
                    Text(viewModel.elapsedFormatted)
                        .font(.system(size: 44, weight: .thin, design: .rounded))
                        .monospacedDigit()

                    Text("4-7-8 助眠呼吸法")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Control
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
                              (viewModel.isPaused ? "play.fill" : "pause.fill") : "moon.fill")
                        Text(viewModel.isSessionActive ?
                             (viewModel.isPaused ? "繼續" : "暫停") : "開始放鬆")
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

                // Sleep checklist
                VStack(alignment: .leading, spacing: 16) {
                    Text("🌙 睡前準備清單")
                        .font(.title3.bold())

                    ForEach($checklist) { $item in
                        HStack(spacing: 12) {
                            Button {
                                item.isChecked.toggle()
                            } label: {
                                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundStyle(item.isChecked ? Color(hex: canvas.accentColorHex) : .gray)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.subheadline.bold())
                                    .strikethrough(item.isChecked)
                                Text(item.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(item.timeLabel)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)

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

// MARK: - Sleep Checklist Item

struct SleepCheckItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let timeLabel: String
    var isChecked: Bool = false

    static let defaults: [SleepCheckItem] = [
        SleepCheckItem(title: "停止咖啡因攝取", detail: "睡前 6-8 小時不攝取咖啡因", timeLabel: "下午2點前"),
        SleepCheckItem(title: "減少螢幕藍光", detail: "開啟夜覽模式或戴藍光眼鏡", timeLabel: "睡前2小時"),
        SleepCheckItem(title: "調暗環境光線", detail: "將房間光線調暗到舒適程度", timeLabel: "睡前1小時"),
        SleepCheckItem(title: "放下手機", detail: "避免刺激性內容與社交媒體", timeLabel: "睡前30分鐘"),
        SleepCheckItem(title: "4-7-8 呼吸練習", detail: "3-6 組放鬆呼吸讓身心平靜", timeLabel: "就寢時"),
    ]
}

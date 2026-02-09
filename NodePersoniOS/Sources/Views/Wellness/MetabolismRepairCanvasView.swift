import SwiftUI
import NodePersonShared

/// Canvas 5 — Metabolism & Self-Repair
/// Metabolic boost, skin rejuvenation, collagen production, body restoration.
struct MetabolismRepairCanvasView: View {
    @State private var viewModel = WellnessViewModel()
    @State private var habits: [DailyHabit] = DailyHabit.defaults
    @State private var selectedPhase: RepairPhase = .breathing
    private let canvas = WellnessCanvas.metabolismRepair

    enum RepairPhase: String, CaseIterable, Identifiable {
        case breathing = "呼吸激活"
        case coldExposure = "冷熱刺激"
        case habits = "日常習慣"
        case progress = "成果預覽"
        var id: String { rawValue }

        var icon: String {
            switch self {
            case .breathing:     return "wind"
            case .coldExposure:  return "thermometer.snowflake"
            case .habits:        return "checklist"
            case .progress:      return "chart.line.uptrend.xyaxis"
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Phase selector tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(RepairPhase.allCases) { phase in
                            Button {
                                withAnimation { selectedPhase = phase }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: phase.icon)
                                        .font(.caption)
                                    Text(phase.rawValue)
                                        .font(.subheadline.bold())
                                }
                                .foregroundStyle(selectedPhase == phase ? .white : Color(hex: canvas.accentColorHex))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    selectedPhase == phase
                                        ? Color(hex: canvas.accentColorHex)
                                        : Color(hex: canvas.accentColorHex).opacity(0.1)
                                )
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 8)

                // Phase content
                switch selectedPhase {
                case .breathing:
                    breathingSection
                case .coldExposure:
                    coldExposureSection
                case .habits:
                    habitsSection
                case .progress:
                    progressSection
                }

                // Benefits at the bottom
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

    // MARK: - Breathing Section

    private var breathingSection: some View {
        VStack(spacing: 24) {
            BreathingCircleView(
                pattern: viewModel.currentPattern,
                phase: viewModel.currentPhase,
                progress: viewModel.phaseProgress,
                scale: viewModel.breathingScale,
                accentHex: canvas.accentColorHex,
                gradientEndHex: canvas.gradientEndHex
            )
            .frame(height: 260)

            VStack(spacing: 6) {
                Text(viewModel.elapsedFormatted)
                    .font(.system(size: 40, weight: .light, design: .rounded))
                    .monospacedDigit()
                Text("力量呼吸法 — 提升代謝")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

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
                          (viewModel.isPaused ? "play.fill" : "pause.fill") : "bolt.fill")
                    Text(viewModel.isSessionActive ?
                         (viewModel.isPaused ? "繼續" : "暫停") : "開始力量呼吸")
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
                    Text("結束練習").font(.subheadline).foregroundStyle(.secondary)
                }
            }

            // Info card
            VStack(alignment: .leading, spacing: 8) {
                Text("💨 力量呼吸法原理")
                    .font(.headline)
                Text("快速深呼吸 30 次後屏息，可以暫時提升血液 pH 值、激活腎上腺素、促進線粒體活化，從而加速整體新陳代謝。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }

    // MARK: - Cold Exposure

    private var coldExposureSection: some View {
        VStack(spacing: 20) {
            // Temperature exposure guide
            VStack(alignment: .leading, spacing: 16) {
                Text("🧊 冷熱交替法")
                    .font(.title3.bold())

                VStack(spacing: 12) {
                    exposureStep(
                        phase: "溫水開始",
                        duration: "2 分鐘",
                        detail: "先用溫水讓身體適應",
                        color: .orange,
                        icon: "flame"
                    )
                    exposureStep(
                        phase: "切換冷水",
                        duration: "30 秒",
                        detail: "轉到冷水，專注呼吸",
                        color: .cyan,
                        icon: "snowflake"
                    )
                    exposureStep(
                        phase: "回到溫水",
                        duration: "1 分鐘",
                        detail: "讓血管重新擴張",
                        color: .orange,
                        icon: "flame"
                    )
                    exposureStep(
                        phase: "冷水結束",
                        duration: "30 秒",
                        detail: "以冷水結束促進代謝",
                        color: .cyan,
                        icon: "snowflake"
                    )
                }
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)

            // Why it works
            VStack(alignment: .leading, spacing: 10) {
                Text("為什麼有效？")
                    .font(.headline)
                infoRow("🔬", "激活棕色脂肪", "冷刺激促進棕色脂肪燃燒熱量")
                infoRow("💪", "促進循環", "血管收縮擴張訓練改善微循環")
                infoRow("✨", "刺激膠原蛋白", "冷熱交替促進皮膚膠原蛋白生成")
                infoRow("🔄", "加速修復", "提高免疫反應與細胞修復速度")
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }

    private func exposureStep(phase: String, duration: String, detail: String, color: Color, icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(phase)
                    .font(.subheadline.bold())
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(duration)
                .font(.caption.bold())
                .foregroundStyle(color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(color.opacity(0.1))
                .clipShape(Capsule())
        }
    }

    private func infoRow(_ emoji: String, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(emoji)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Daily Habits

    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📋 每日修復習慣")
                .font(.title3.bold())
                .padding(.horizontal)

            ForEach($habits) { $habit in
                HStack(spacing: 12) {
                    Button {
                        habit.isCompleted.toggle()
                    } label: {
                        Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(habit.isCompleted ? Color(hex: canvas.accentColorHex) : .gray)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(habit.title)
                            .font(.subheadline.bold())
                            .strikethrough(habit.isCompleted)
                        Text(habit.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: habit.icon)
                        .foregroundStyle(Color(hex: canvas.accentColorHex).opacity(0.5))
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
            }

            // Completion count
            let completed = habits.filter(\.isCompleted).count
            HStack {
                Spacer()
                Text("完成 \(completed)/\(habits.count)")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color(hex: canvas.accentColorHex))
                Spacer()
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("✨ 預期改變時間軸")
                .font(.title3.bold())
                .padding(.horizontal)

            VStack(spacing: 0) {
                timelineRow("1-2 週", "精神變好", "醒來更有精神，白天精力充沛", "sparkles", true)
                timelineLine()
                timelineRow("2-4 週", "膚質改善", "臉部開始變得更飽滿，光澤度提升", "face.smiling", true)
                timelineLine()
                timelineRow("1-2 月", "體態變化", "整體體態更緊實，代謝率明顯提升", "figure.walk", false)
                timelineLine()
                timelineRow("2-3 月", "紋路變淺", "臉上紋路逐漸變淺，膠原蛋白開始回補", "wand.and.stars", false)
                timelineLine()
                timelineRow("3-6 月", "全面轉變", "整體體態 Better Shape，臉龐飽滿，皮膚緊緻", "star.fill", false)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }

    private func timelineRow(_ period: String, _ title: String, _ detail: String, _ icon: String, _ reached: Bool) -> some View {
        HStack(spacing: 14) {
            // Timeline dot
            ZStack {
                Circle()
                    .fill(reached ? Color(hex: canvas.accentColorHex) : Color.gray.opacity(0.3))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(reached ? .white : .gray)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(period)
                        .font(.caption.bold())
                        .foregroundStyle(Color(hex: canvas.accentColorHex))
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text(title)
                        .font(.subheadline.bold())
                }
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func timelineLine() -> some View {
        HStack {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 2, height: 20)
                .padding(.leading, 17) // center under dot
            Spacer()
        }
    }

    // MARK: - Benefits Card

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

// MARK: - Daily Habit Model

struct DailyHabit: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let icon: String
    var isCompleted: Bool = false

    static let defaults: [DailyHabit] = [
        DailyHabit(title: "充足睡眠", detail: "7-8 小時高品質睡眠", icon: "moon.zzz"),
        DailyHabit(title: "充足飲水", detail: "至少 2000ml 純水", icon: "drop.fill"),
        DailyHabit(title: "力量呼吸", detail: "30 次深呼吸 × 3 輪", icon: "wind"),
        DailyHabit(title: "冷熱交替", detail: "淋浴時冷熱水交替", icon: "thermometer.snowflake"),
        DailyHabit(title: "間歇性斷食", detail: "16/8 斷食窗口", icon: "clock.fill"),
        DailyHabit(title: "運動", detail: "至少 20 分鐘中等強度運動", icon: "figure.run"),
        DailyHabit(title: "日曬", detail: "早晨 10 分鐘日光照射", icon: "sun.max.fill"),
    ]
}

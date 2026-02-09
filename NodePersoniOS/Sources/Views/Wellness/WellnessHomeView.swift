import SwiftUI
import NodePersonShared

/// Wellness home dashboard — shows all 5 canvases with daily progress.
struct WellnessHomeView: View {
    @State private var viewModel = WellnessViewModel()
    @State private var selectedCanvas: WellnessCanvas?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Daily progress header
                    dailyProgressHeader

                    // Canvas grid
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16),
                        ],
                        spacing: 16
                    ) {
                        ForEach(WellnessCanvas.allCases) { canvas in
                            NavigationLink(value: canvas) {
                                CanvasCardView(
                                    canvas: canvas,
                                    streakDays: viewModel.streak.currentStreak,
                                    sessionsToday: viewModel.dailyProgress?.sessionsCompleted ?? 0
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)

                    // Streak banner
                    if viewModel.streak.currentStreak > 0 {
                        streakBanner
                    }

                    // Benefits preview
                    benefitsSection
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Wellness")
            .navigationDestination(for: WellnessCanvas.self) { canvas in
                canvasDetailView(for: canvas)
            }
        }
    }

    // MARK: - Daily Progress

    private var dailyProgressHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // Progress ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: dailyCompletionRatio)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#7C3AED"), Color(hex: "#EC4899")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 2) {
                        Text("\(viewModel.dailyProgress?.canvasCount ?? 0)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        Text("/ 5")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 72, height: 72)

                VStack(alignment: .leading, spacing: 4) {
                    Text("今日進度")
                        .font(.headline)
                    Text("\(viewModel.dailyProgress?.sessionsCompleted ?? 0) 次練習 • \(formattedMinutes) 分鐘")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }

    private var dailyCompletionRatio: Double {
        Double(viewModel.dailyProgress?.canvasCount ?? 0) / 5.0
    }

    private var formattedMinutes: String {
        String(format: "%.0f", viewModel.dailyProgress?.totalMinutes ?? 0)
    }

    // MARK: - Streak Banner

    private var streakBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("🔥 連續 \(viewModel.streak.currentStreak) 天")
                    .font(.headline)
                Text("最長紀錄：\(viewModel.streak.longestStreak) 天 • 共 \(viewModel.streak.totalSessions) 次練習")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.1), Color.red.opacity(0.05)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    // MARK: - Benefits

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("你可以獲得的改變")
                .font(.title3.bold())
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(WellnessCanvas.allCases) { canvas in
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: canvas.iconName)
                                .font(.title3)
                                .foregroundStyle(Color(hex: canvas.accentColorHex))

                            Text(canvas.title)
                                .font(.subheadline.bold())

                            ForEach(canvas.benefits.prefix(3), id: \.self) { benefit in
                                HStack(alignment: .top, spacing: 4) {
                                    Text("•")
                                        .foregroundStyle(Color(hex: canvas.accentColorHex))
                                    Text(benefit)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding()
                        .frame(width: 180, alignment: .leading)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Canvas Navigation

    @ViewBuilder
    private func canvasDetailView(for canvas: WellnessCanvas) -> some View {
        switch canvas {
        case .flowState:            FlowStateCanvasView()
        case .betterSleep:          SleepQualityCanvasView()
        case .comfortVision:        ComfortVisionCanvasView()
        case .athleticPerformance:  AthleticPerformanceCanvasView()
        case .metabolismRepair:     MetabolismRepairCanvasView()
        }
    }
}

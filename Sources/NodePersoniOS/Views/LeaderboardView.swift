import SwiftUI
import NodePersonShared

/// Leaderboard of top NodePersons by influence score.
struct LeaderboardView: View {
    @State private var leaderboard: [LeaderboardEntry] = []
    @State private var stats: [NodeTypeStats] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("載入中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    leaderboardContent
                }
            }
            .navigationTitle("排行榜")
            .task {
                await loadData()
            }
            .refreshable {
                await loadData()
            }
        }
    }

    private var leaderboardContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats overview
                if !stats.isEmpty {
                    statsSection
                }

                // Top NodePersons
                if !leaderboard.isEmpty {
                    rankingSection
                }
            }
            .padding()
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("各類型統計")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(stats, id: \.nodeType) { stat in
                    VStack(spacing: 6) {
                        if let type = NodeType(rawValue: stat.nodeType) {
                            Image(systemName: type.iconName)
                                .font(.title3)
                                .foregroundStyle(Color(hex: type.colorHex))
                        }
                        Text(stat.label)
                            .font(.caption.bold())
                        HStack(spacing: 12) {
                            VStack {
                                Text("\(stat.count)")
                                    .font(.headline)
                                Text("人數")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            VStack {
                                Text(String(format: "%.0f", stat.avgInfluence))
                                    .font(.headline)
                                Text("平均")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private var rankingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("影響力排行")
                .font(.headline)

            ForEach(Array(leaderboard.enumerated()), id: \.element.id) { index, entry in
                HStack(spacing: 12) {
                    // Rank
                    Text("#\(index + 1)")
                        .font(.headline)
                        .foregroundStyle(rankColor(index))
                        .frame(width: 40)

                    // Type icon
                    if let type = entry.nodeTypeEnum {
                        Image(systemName: type.iconName)
                            .foregroundStyle(Color(hex: type.colorHex))
                    }

                    // Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.name)
                            .font(.subheadline.bold())
                        HStack {
                            if let district = entry.district {
                                Text(district)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Text("•")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(entry.successfulMatches) 配對")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    // Score
                    Text("\(Int(entry.influenceScore))")
                        .font(.title3.bold())
                        .foregroundStyle(Color(hex: "#EC4899"))
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func rankColor(_ index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return .gray
        case 2: return .orange
        default: return .secondary
        }
    }

    private func loadData() async {
        isLoading = true
        do {
            async let fetchedLeaderboard = APIClient.shared.fetchLeaderboard()
            async let fetchedStats = APIClient.shared.fetchStats()
            leaderboard = try await fetchedLeaderboard
            stats = try await fetchedStats
        } catch {
            // Silently handle for now
        }
        isLoading = false
    }
}

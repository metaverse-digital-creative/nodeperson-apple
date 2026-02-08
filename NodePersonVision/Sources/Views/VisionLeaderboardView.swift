import SwiftUI
import NodePersonShared

/// visionOS spatial leaderboard with large cards.
struct VisionLeaderboardView: View {
    @State private var leaderboard: [LeaderboardEntry] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    ProgressView("載入中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 20) {
                        // Top 3 podium
                        if leaderboard.count >= 3 {
                            podiumView
                        }

                        // Full ranking
                        ForEach(Array(leaderboard.enumerated()), id: \.element.id) { index, entry in
                            HStack(spacing: 20) {
                                Text("#\(index + 1)")
                                    .font(.title.bold())
                                    .foregroundStyle(rankColor(index))
                                    .frame(width: 60)

                                if let type = entry.nodeTypeEnum {
                                    Image(systemName: type.iconName)
                                        .font(.title2)
                                        .foregroundStyle(Color(hex: type.colorHex))
                                        .frame(width: 50, height: 50)
                                        .background(Color(hex: type.colorHex).opacity(0.1))
                                        .clipShape(Circle())
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.name)
                                        .font(.title3.bold())
                                    HStack {
                                        Text(entry.nodeTypeLabel ?? entry.nodeType)
                                        if let district = entry.district {
                                            Text("•")
                                            Text(district)
                                        }
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing) {
                                    Text("\(Int(entry.influenceScore))")
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color(hex: "#EC4899"))
                                    Text("影響力")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding()
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(32)
                }
            }
            .navigationTitle("影響力排行榜")
        }
        .task {
            await loadData()
        }
    }

    @ViewBuilder
    private var podiumView: some View {
        HStack(alignment: .bottom, spacing: 16) {
            // 2nd place
            podiumCard(entry: leaderboard[1], rank: 2, height: 140)
            // 1st place
            podiumCard(entry: leaderboard[0], rank: 1, height: 180)
            // 3rd place
            podiumCard(entry: leaderboard[2], rank: 3, height: 110)
        }
    }

    private func podiumCard(entry: LeaderboardEntry, rank: Int, height: CGFloat) -> some View {
        VStack(spacing: 8) {
            if let type = entry.nodeTypeEnum {
                Image(systemName: type.iconName)
                    .font(.title)
                    .foregroundStyle(Color(hex: type.colorHex))
            }
            Text(entry.name)
                .font(.headline)
            Text("\(Int(entry.influenceScore))")
                .font(.title.bold())
                .foregroundStyle(Color(hex: "#EC4899"))
            Text(rankEmoji(rank))
                .font(.title)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        )
    }

    private func rankColor(_ index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return .gray
        case 2: return .orange
        default: return .secondary
        }
    }

    private func rankEmoji(_ rank: Int) -> String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }

    private func loadData() async {
        isLoading = true
        do {
            leaderboard = try await APIClient.shared.fetchLeaderboard()
        } catch {}
        isLoading = false
    }
}

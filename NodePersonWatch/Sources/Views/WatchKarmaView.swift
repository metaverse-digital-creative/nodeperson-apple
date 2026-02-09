import SwiftUI

/// watchOS Karma view — compact 貢獻紀錄 (contribution record).
struct WatchKarmaView: View {
    /// NodePerson ID — configurable, defaults to "demo" for dev.
    var nodePersonId: String = {
        // TODO: Replace with actual user session ID
        ProcessInfo.processInfo.environment["NODEPERSON_ID"] ?? "demo"
    }()

    @State private var karma: KarmaScore?
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("載入中...")
                    .padding()
            } else if let karma = karma {
                VStack(spacing: 12) {
                    // Ring chart
                    KarmaRingView(karma: karma, ringWidth: 6, size: 100)
                        .padding(.top, 4)

                    // Level and delta
                    HStack {
                        Text("\(karma.levelEmoji) Lv.\(karma.level)")
                            .font(.caption.bold())
                        Spacer()
                        Text(karma.deltaString)
                            .font(.caption.bold())
                            .foregroundColor(karma.weeklyDelta >= 0 ? .green : .red)
                    }
                    .padding(.horizontal)

                    // Streak
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.caption2)
                        Text("連續 \(karma.activeStreak) 天")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    // Mini legend
                    VStack(alignment: .leading, spacing: 4) {
                        miniRow("♻️", karma.recyclingScore, .green)
                        miniRow("🤝", karma.referralScore, .orange)
                        miniRow("🏘️", karma.communityScore, .blue)
                        miniRow("💎", karma.trustScore, .purple)
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("無法載入")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("貢獻紀錄")
        .task {
            await loadKarma()
        }
    }

    private func miniRow(_ emoji: String, _ score: Double, _ color: Color) -> some View {
        HStack(spacing: 4) {
            Text(emoji)
                .font(.caption2)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(color.opacity(0.2))
                        .frame(height: 4)
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(min(score / 100, 1.0)), height: 4)
                }
            }
            .frame(height: 4)
            Text(String(format: "%.0f", score))
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .frame(width: 24, alignment: .trailing)
        }
    }

    private func loadKarma() async {
        isLoading = true
        defer { isLoading = false }

        guard let url = APIEndpoint.karma(nodePersonId: nodePersonId).url() else {
            karma = .preview // Offline fallback
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            karma = try JSONDecoder().decode(KarmaScore.self, from: data)
        } catch {
            print("Failed to load karma: \(error)")
            karma = .preview // Offline fallback — always show something
        }
    }
}

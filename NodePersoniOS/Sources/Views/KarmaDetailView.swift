import SwiftUI

/// Full Karma detail view for iOS — 貢獻紀錄 (Contribution Record), not leaderboard.
struct KarmaDetailView: View {
    let nodePersonId: String
    @State private var karma: KarmaScore?
    @State private var contributions: [ContributionRecord] = []
    @State private var isLoading = true
    @State private var animateRing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if isLoading {
                    ProgressView()
                        .padding(40)
                } else if let karma = karma {
                    // Header
                    VStack(spacing: 8) {
                        Text("\(karma.levelEmoji) Lv.\(karma.level)")
                            .font(.title2.bold())
                        Text(karma.levelTitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)

                    // Ring chart
                    KarmaRingView(karma: karma, ringWidth: 14, size: 200)
                        .scaleEffect(animateRing ? 1.0 : 0.8)
                        .opacity(animateRing ? 1.0 : 0.5)
                        .animation(.easeOut(duration: 0.6), value: animateRing)
                        .onAppear { animateRing = true }

                    // Weekly delta & streak
                    HStack(spacing: 24) {
                        StatBadge(
                            title: "週變化",
                            value: karma.deltaString,
                            color: karma.weeklyDelta >= 0 ? .green : .red,
                            icon: karma.weeklyDelta >= 0 ? "arrow.up.right" : "arrow.down.right"
                        )
                        StatBadge(
                            title: "連續天數",
                            value: "\(karma.activeStreak)",
                            color: .orange,
                            icon: "flame.fill"
                        )
                        StatBadge(
                            title: "總 Karma",
                            value: String(format: "%.1f", karma.totalKarma),
                            color: .blue,
                            icon: "star.fill"
                        )
                    }
                    .padding(.horizontal)

                    // Dimension breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Karma 維度")
                            .font(.headline)
                            .padding(.horizontal)

                        KarmaLegendView(karma: karma)
                            .padding(.horizontal)

                        // Progress bars
                        VStack(spacing: 8) {
                            DimensionBar(label: "回收", score: karma.recyclingScore, color: .green, icon: "♻️")
                            DimensionBar(label: "轉介", score: karma.referralScore, color: .orange, icon: "🤝")
                            DimensionBar(label: "社區", score: karma.communityScore, color: .blue, icon: "🏘️")
                            DimensionBar(label: "信任", score: karma.trustScore, color: .purple, icon: "💎")
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Contribution history (貢獻紀錄)
                    if !contributions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("貢獻紀錄")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(contributions) { record in
                                ContributionRow(record: record)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                } else {
                    Text("無法載入 Karma Score")
                        .foregroundColor(.secondary)
                        .padding(40)
                }
            }
        }
        .navigationTitle("我的貢獻紀錄")
        .task {
            await loadKarma()
            await loadContributions()
        }
        .refreshable {
            await refresh()
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
            karma = .preview // Offline fallback
        }
    }

    private func loadContributions() async {
        guard let url = APIEndpoint.contributions(nodePersonId: nodePersonId).url() else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ContributionResponse.self, from: data)
            contributions = response.records
        } catch {
            print("Failed to load contributions: \(error)")
        }
    }

    private func refresh() async {
        guard let url = APIEndpoint.refreshKarma(nodePersonId: nodePersonId).url() else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            karma = try JSONDecoder().decode(KarmaScore.self, from: data)
        } catch {
            print("Failed to refresh karma: \(error)")
        }
    }
}

// ─── Contribution Row ───

struct ContributionRow: View {
    let record: ContributionRecord

    var body: some View {
        HStack(spacing: 12) {
            Text(record.typeEmoji)
                .font(.title3)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.description)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text(formattedDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("+\(String(format: "%.0f", record.karmaPoints))")
                .font(.caption.bold())
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
        }
        .padding(.horizontal)
    }

    private var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: record.timestamp) else {
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: record.timestamp) else { return record.timestamp }
            return RelativeDateTimeFormatter().localizedString(for: date, relativeTo: Date())
        }
        return RelativeDateTimeFormatter().localizedString(for: date, relativeTo: Date())
    }
}

// ─── Helper Views ───

struct StatBadge: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.primary)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DimensionBar: View {
    let label: String
    let score: Double
    let color: Color
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Text(icon)
                .font(.caption)
                .frame(width: 24)
            Text(label)
                .font(.caption)
                .frame(width: 36, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(color.opacity(0.15))
                    Capsule()
                        .fill(color.gradient)
                        .frame(width: geo.size.width * CGFloat(min(score / 100, 1.0)))
                }
            }
            .frame(height: 8)
            Text(String(format: "%.0f", score))
                .font(.caption.bold())
                .frame(width: 28, alignment: .trailing)
        }
    }
}

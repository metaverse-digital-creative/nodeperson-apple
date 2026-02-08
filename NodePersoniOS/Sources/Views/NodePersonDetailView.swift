import SwiftUI
import NodePersonShared

/// Detailed view of a single NodePerson with referral stats and conversation script.
struct NodePersonDetailView: View {
    @State private var viewModel: NodePersonDetailViewModel

    init(nodePerson: NodePerson) {
        _viewModel = State(initialValue: NodePersonDetailViewModel(nodePerson: nodePerson))
    }

    var body: some View {
        ScrollView {
            if let np = viewModel.nodePerson {
                VStack(spacing: 20) {
                    // Header card
                    headerCard(np)

                    // Influence metrics
                    metricsGrid(np)

                    // Conversation script (if available)
                    if let script = viewModel.script {
                        scriptCard(script)
                    }

                    // Referral history
                    if let referrals = np.referrals, !referrals.isEmpty {
                        referralSection(referrals)
                    }

                    // Notes
                    if let notes = np.notes, !notes.isEmpty {
                        notesSection(notes)
                    }
                }
                .padding()
            } else if viewModel.isLoading {
                ProgressView("載入中...")
                    .frame(maxHeight: .infinity)
            }
        }
        .navigationTitle(viewModel.nodePerson?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Header

    private func headerCard(_ np: NodePerson) -> some View {
        VStack(spacing: 12) {
            // Type icon
            if let type = np.nodeTypeEnum {
                Image(systemName: type.iconName)
                    .font(.largeTitle)
                    .foregroundStyle(Color(hex: type.colorHex))
                    .frame(width: 70, height: 70)
                    .background(Color(hex: type.colorHex).opacity(0.15))
                    .clipShape(Circle())
            }

            Text(np.name)
                .font(.title2.bold())

            Text(np.displayTypeLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                if let district = np.district {
                    Label(district, systemImage: "mappin.circle.fill")
                        .font(.caption)
                }
                if let region = np.region {
                    Label(region, systemImage: "map.fill")
                        .font(.caption)
                }
                Label(np.isActive ? "活躍" : "停用", systemImage: np.isActive ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(np.isActive ? .green : .red)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Metrics

    private func metricsGrid(_ np: NodePerson) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("影響力指標")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12) {
                metricCard(
                    value: "\(Int(np.influenceScore))",
                    label: "影響力分數",
                    icon: "star.fill",
                    color: .orange
                )
                metricCard(
                    value: "\(np.communityLinks)",
                    label: "社區連結",
                    icon: "link",
                    color: .blue
                )
                metricCard(
                    value: "\(np.referralCount)",
                    label: "轉介數",
                    icon: "arrow.triangle.branch",
                    color: .green
                )
                metricCard(
                    value: "\(np.successfulMatches)",
                    label: "成功配對",
                    icon: "checkmark.seal.fill",
                    color: .purple
                )
            }

            // Recalculate button
            Button {
                Task { await viewModel.recalculateInfluence() }
            } label: {
                Label("重新計算影響力", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private func metricCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Script Card

    private func scriptCard(_ script: ConversationScript) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("對話腳本", systemImage: "text.bubble.fill")
                .font(.headline)

            // Anti-pattern
            HStack(alignment: .top) {
                Text("❌")
                Text(script.antiPattern)
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .strikethrough()
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Correct opener
            HStack(alignment: .top) {
                Text("✅")
                Text(script.correctOpener)
                    .font(.subheadline)
                    .foregroundStyle(.green)
                    .bold()
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.green.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Follow-ups
            VStack(alignment: .leading, spacing: 6) {
                Text("延伸問題")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                ForEach(Array(script.followUps.enumerated()), id: \.offset) { _, followUp in
                    HStack(alignment: .top) {
                        Text("👉")
                        Text(followUp)
                            .font(.caption)
                    }
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.blue.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Referrals

    private func referralSection(_ referrals: [Referral]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("轉介歷史")
                .font(.headline)

            ForEach(referrals) { referral in
                HStack {
                    Image(systemName: referral.converted ? "checkmark.circle.fill" : "clock.fill")
                        .foregroundStyle(referral.converted ? .green : .orange)
                    VStack(alignment: .leading) {
                        Text(referral.source ?? "直接轉介")
                            .font(.subheadline)
                        Text(referral.createdAt.prefix(10))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(referral.converted ? "已轉換" : "待轉換")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(referral.converted ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Notes

    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("備註")
                .font(.headline)
            Text(notes)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

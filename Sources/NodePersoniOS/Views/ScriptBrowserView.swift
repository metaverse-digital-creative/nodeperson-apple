import SwiftUI
import NodePersonShared

/// Browse all conversation scripts with the core principle prominently displayed.
struct ScriptBrowserView: View {
    @State private var viewModel = ScriptViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("載入中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    scriptList
                }
            }
            .navigationTitle("對話腳本")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("全部") { viewModel.filterNodeType = nil }
                        Divider()
                        ForEach(NodeType.allCases) { type in
                            Button {
                                viewModel.filterNodeType = type
                            } label: {
                                Label(type.label, systemImage: type.iconName)
                            }
                        }
                    } label: {
                        Label("篩選", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .task {
                await viewModel.loadAll()
            }
        }
    }

    private var scriptList: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Core principle card (always visible)
                if let principle = viewModel.corePrinciple {
                    corePrincipleCard(principle)
                }

                // Script cards
                ForEach(viewModel.filteredScripts) { script in
                    ScriptCardView(script: script)
                }
            }
            .padding()
        }
    }

    private func corePrincipleCard(_ principle: CorePrinciple) -> some View {
        VStack(spacing: 14) {
            Text(principle.title)
                .font(.title3.bold())

            Text(principle.subtitle)
                .font(.headline)
                .foregroundStyle(Color(hex: "#EC4899"))

            VStack(spacing: 8) {
                Text(principle.doNot)
                    .font(.body)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(principle.doThis)
                    .font(.body.bold())
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color.primary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(principle.explanation)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color(hex: "#EC4899").opacity(0.1), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#EC4899").opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Script Card

struct ScriptCardView: View {
    let script: ConversationScript
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                if let type = NodeType(rawValue: script.nodeType) {
                    Image(systemName: type.iconName)
                        .foregroundStyle(Color(hex: type.colorHex))
                }
                Text(script.nodeTypeLabel)
                    .font(.headline)
                Spacer()
                Text(script.signalType)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())
            }

            // Why critical
            Text(script.whyCritical)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            // Anti-pattern vs correct
            HStack(alignment: .top, spacing: 8) {
                Text("❌")
                Text(script.antiPattern)
                    .font(.subheadline)
                    .foregroundStyle(.red.opacity(0.8))
                    .strikethrough()
            }

            HStack(alignment: .top, spacing: 8) {
                Text("✅")
                Text(script.correctOpener)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
            }

            // Expandable follow-ups
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text("延伸問題")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)

                    ForEach(Array(script.followUps.enumerated()), id: \.offset) { i, followUp in
                        HStack(alignment: .top, spacing: 6) {
                            Text("\(i + 1).")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            Text(followUp)
                                .font(.subheadline)
                        }
                    }
                }
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Button {
                withAnimation(.spring(duration: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(isExpanded ? "收起" : "查看延伸問題")
                        .font(.caption)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .foregroundStyle(Color(hex: "#EC4899"))
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

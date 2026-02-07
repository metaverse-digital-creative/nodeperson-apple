import SwiftUI
import NodePersonShared

/// Swipeable conversation script cards for field use on Apple Watch.
struct WatchScriptView: View {
    @State private var scripts: [ConversationScript] = []
    @State private var isLoading = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if scripts.isEmpty {
                Text("無腳本")
                    .foregroundStyle(.secondary)
            } else {
                TabView {
                    // Core principle card
                    VStack(spacing: 6) {
                        Text("核心原則")
                            .font(.caption.bold())
                        Text("❌ 問商品")
                            .font(.caption2)
                            .foregroundStyle(.red)
                        Text("✅ 問煩惱")
                            .font(.caption2.bold())
                            .foregroundStyle(.green)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .containerBackground(Color(hex: "#EC4899").opacity(0.2), for: .tabView)

                    // Individual script cards
                    ForEach(scripts) { script in
                        WatchScriptCard(script: script)
                    }
                }
                .tabViewStyle(.verticalPage)
            }
        }
        .navigationTitle("對話腳本")
        .task {
            await loadScripts()
        }
    }

    private func loadScripts() async {
        isLoading = true
        do {
            scripts = try await APIClient.shared.fetchScripts()
        } catch {
            // Silent fail
        }
        isLoading = false
    }
}

struct WatchScriptCard: View {
    let script: ConversationScript

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                // Type label
                HStack {
                    if let type = NodeType(rawValue: script.nodeType) {
                        Image(systemName: type.iconName)
                            .font(.caption)
                            .foregroundStyle(Color(hex: type.colorHex))
                    }
                    Text(script.nodeTypeLabel)
                        .font(.caption.bold())
                }

                Divider()

                // Correct opener (the main content for watch)
                Text(script.correctOpener)
                    .font(.caption2)
                    .foregroundStyle(.primary)

                // Signal type
                Text(script.signalType)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 4)
        }
    }
}

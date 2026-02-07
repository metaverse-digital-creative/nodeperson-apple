import SwiftUI
import NodePersonShared

/// visionOS spatial script browser.
struct VisionScriptView: View {
    @State private var scripts: [ConversationScript] = []
    @State private var principle: CorePrinciple?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Core principle — large spatial card
                    if let principle {
                        VStack(spacing: 16) {
                            Text(principle.title)
                                .font(.largeTitle.bold())

                            Text(principle.subtitle)
                                .font(.title)
                                .foregroundStyle(Color(hex: "#EC4899"))

                            HStack(spacing: 24) {
                                VStack(spacing: 8) {
                                    Text(principle.doNot)
                                        .font(.title3)
                                        .foregroundStyle(.red)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 16))

                                VStack(spacing: 8) {
                                    Text(principle.doThis)
                                        .font(.title3.bold())
                                        .foregroundStyle(.green)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }

                            Text(principle.explanation)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(24)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }

                    // Grid of script cards
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16),
                    ], spacing: 16) {
                        ForEach(scripts) { script in
                            VisionScriptCard(script: script)
                        }
                    }
                }
                .padding(32)
            }
            .navigationTitle("對話腳本")
        }
        .task {
            isLoading = true
            do {
                async let s = APIClient.shared.fetchScripts()
                async let p = APIClient.shared.fetchCorePrinciple()
                scripts = try await s
                principle = try await p
            } catch {}
            isLoading = false
        }
    }
}

struct VisionScriptCard: View {
    let script: ConversationScript

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                if let type = NodeType(rawValue: script.nodeType) {
                    Image(systemName: type.iconName)
                        .font(.title2)
                        .foregroundStyle(Color(hex: type.colorHex))
                }
                VStack(alignment: .leading) {
                    Text(script.nodeTypeLabel)
                        .font(.headline)
                    Text(script.signalType)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Divider()

            Text(script.whyCritical)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Opener
            Text(script.correctOpener)
                .font(.body.bold())
                .foregroundStyle(.primary)

            // Follow-ups
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(script.followUps.enumerated()), id: \.offset) { _, prompt in
                    HStack(alignment: .top) {
                        Text("👉")
                            .font(.caption)
                        Text(prompt)
                            .font(.caption)
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

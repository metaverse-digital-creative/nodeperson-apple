import SwiftUI
import NodePersonShared

/// watchOS main view — quick lookup and conversation prompts.
struct WatchContentView: View {
    @State private var nodePersons: [NodePerson] = []
    @State private var isLoading = false
    @State private var showingScripts = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else {
                    watchList
                }
            }
            .navigationTitle("節點人物")
        }
        .task {
            await loadData()
        }
    }

    private var watchList: some View {
        List {
            // Quick principle reminder
            Section {
                VStack(spacing: 4) {
                    Text("👉 問煩惱，不問商品")
                        .font(.caption2.bold())
                        .foregroundStyle(Color(hex: "#EC4899"))
                }
                .frame(maxWidth: .infinity)
            }

            // Script button
            Section {
                NavigationLink("📋 對話腳本") {
                    WatchScriptView()
                }
            }

            // Node persons
            Section("最近活躍") {
                ForEach(nodePersons.prefix(10)) { person in
                    WatchPersonRow(person: person)
                }
            }
        }
    }

    private func loadData() async {
        isLoading = true
        do {
            nodePersons = try await APIClient.shared.fetchNodePersons()
        } catch {
            // Silent fail on watch
        }
        isLoading = false
    }
}

// MARK: - Watch Person Row

struct WatchPersonRow: View {
    let person: NodePerson

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if let type = person.nodeTypeEnum {
                    Image(systemName: type.iconName)
                        .font(.caption)
                        .foregroundStyle(Color(hex: type.colorHex))
                }
                Text(person.name)
                    .font(.headline)
            }
            HStack {
                Text(person.displayTypeLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(person.influenceScore))")
                    .font(.caption.bold())
            }
        }
    }
}

// MARK: - Color Extension (watchOS)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

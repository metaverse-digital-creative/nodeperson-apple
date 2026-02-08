import SwiftUI
import NodePersonShared

/// visionOS spatial content view with tab-based navigation.
struct VisionContentView: View {
    @State private var selectedTab = "wellness"

    var body: some View {
        TabView(selection: $selectedTab) {
            VisionWellnessHomeView()
                .tabItem {
                    Label("Wellness", systemImage: "sparkles")
                }
                .tag("wellness")

            VisionNodePersonsView()
                .tabItem {
                    Label("節點人物", systemImage: "person.3.fill")
                }
                .tag("people")

            VisionScriptView()
                .tabItem {
                    Label("對話腳本", systemImage: "text.bubble.fill")
                }
                .tag("scripts")

            VisionLeaderboardView()
                .tabItem {
                    Label("排行榜", systemImage: "trophy.fill")
                }
                .tag("leaderboard")
        }
    }
}

// MARK: - Vision Node Persons View

struct VisionNodePersonsView: View {
    @State private var viewModel = NodePersonListViewModel()
    @State private var selectedPerson: NodePerson?

    var body: some View {
        NavigationSplitView {
            // Sidebar — type filter + list
            List(selection: $selectedPerson) {
                ForEach(viewModel.groupedByType, id: \.0) { type, persons in
                    Section {
                        ForEach(persons) { person in
                            NavigationLink(value: person) {
                                VisionPersonRow(person: person)
                            }
                        }
                    } header: {
                        HStack {
                            Image(systemName: type.iconName)
                                .foregroundStyle(Color(hex: type.colorHex))
                            Text(type.label)
                            Spacer()
                            Text(type.whyCritical)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("節點人物網絡")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("全部") { viewModel.clearFilters() }
                        Divider()
                        ForEach(NodeType.allCases) { type in
                            Button {
                                viewModel.selectedNodeType = type
                            } label: {
                                Label(type.label, systemImage: type.iconName)
                            }
                        }
                    } label: {
                        Label("篩選", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        } detail: {
            if let person = selectedPerson {
                VisionPersonDetailView(person: person)
            } else {
                // Welcome / principle card
                VStack(spacing: 24) {
                    Image(systemName: "person.3.sequence.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color(hex: "#EC4899"))

                    Text("NodePerson 信任中繼站")
                        .font(.largeTitle.bold())

                    Text("每座城市 5-7 個節點人物")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        Text("❌ 你有沒有東西要賣？")
                            .foregroundStyle(.red)
                            .strikethrough()
                        Text("✅ 最近有沒有誰在煩惱怎麼處理？")
                            .foregroundStyle(.green)
                            .bold()
                    }
                    .font(.title3)
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    Text("👉 問的是煩惱，不是商品")
                        .font(.headline)
                        .foregroundStyle(Color(hex: "#EC4899"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await viewModel.loadNodePersons()
        }
    }
}

// MARK: - Vision Person Row

struct VisionPersonRow: View {
    let person: NodePerson

    var body: some View {
        HStack(spacing: 16) {
            if let type = person.nodeTypeEnum {
                Image(systemName: type.iconName)
                    .font(.title2)
                    .foregroundStyle(Color(hex: type.colorHex))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: type.colorHex).opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(person.name)
                    .font(.headline)
                HStack {
                    Text(person.displayTypeLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let district = person.district {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(district)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Text("\(Int(person.influenceScore))")
                .font(.title3.bold())
                .foregroundStyle(Color(hex: "#EC4899"))
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Vision Person Detail

struct VisionPersonDetailView: View {
    let person: NodePerson
    @State private var script: ConversationScript?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Large header
                HStack(spacing: 20) {
                    if let type = person.nodeTypeEnum {
                        Image(systemName: type.iconName)
                            .font(.system(size: 40))
                            .foregroundStyle(Color(hex: type.colorHex))
                            .frame(width: 80, height: 80)
                            .background(Color(hex: type.colorHex).opacity(0.1))
                            .clipShape(Circle())
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(person.name)
                            .font(.largeTitle.bold())
                        Text(person.displayTypeLabel)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        HStack {
                            if let district = person.district {
                                Label(district, systemImage: "mappin")
                            }
                            if let region = person.region {
                                Label(region, systemImage: "map")
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Large influence score
                    VStack {
                        Text("\(Int(person.influenceScore))")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: "#EC4899"))
                        Text("影響力")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // Metrics
                HStack(spacing: 16) {
                    visionMetric(value: "\(person.communityLinks)", label: "社區連結", icon: "link", color: .blue)
                    visionMetric(value: "\(person.referralCount)", label: "轉介數", icon: "arrow.triangle.branch", color: .green)
                    visionMetric(value: "\(person.successfulMatches)", label: "成功配對", icon: "checkmark.seal.fill", color: .purple)
                    visionMetric(value: "\(person.reachEstimate)", label: "估計觸及", icon: "person.2.wave.2", color: .orange)
                }

                // Conversation script
                if let script {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("對話腳本")
                            .font(.title2.bold())

                        HStack(alignment: .top, spacing: 20) {
                            // Don't
                            VStack(alignment: .leading, spacing: 8) {
                                Text("❌ 不要這樣說")
                                    .font(.headline)
                                    .foregroundStyle(.red)
                                Text(script.antiPattern)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .strikethrough()
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                            // Do
                            VStack(alignment: .leading, spacing: 8) {
                                Text("✅ 這樣開口")
                                    .font(.headline)
                                    .foregroundStyle(.green)
                                Text(script.correctOpener)
                                    .font(.body.bold())
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.green.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        // Follow-ups in spatial layout
                        VStack(alignment: .leading, spacing: 8) {
                            Text("延伸問題")
                                .font(.headline)
                            ForEach(Array(script.followUps.enumerated()), id: \.offset) { i, prompt in
                                HStack(alignment: .top) {
                                    Text("👉")
                                    Text(prompt)
                                        .font(.body)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
            }
            .padding(32)
        }
        .task {
            do {
                let scripts = try await APIClient.shared.fetchScripts(nodeType: person.nodeType)
                script = scripts.first
            } catch {}
        }
    }

    private func visionMetric(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Color Extension (visionOS)

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

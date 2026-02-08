import SwiftUI
import NodePersonShared

/// Filterable list of NodePersons grouped by type.
struct NodePersonListView: View {
    @State private var viewModel = NodePersonListViewModel()
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("載入中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView {
                        Label("連線失敗", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("重試") {
                            Task { await viewModel.loadNodePersons() }
                        }
                    }
                } else {
                    nodePersonList
                }
            }
            .navigationTitle("節點人物")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
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
                        Label(
                            viewModel.selectedNodeType?.label ?? "篩選",
                            systemImage: "line.3.horizontal.decrease.circle"
                        )
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddNodePersonView()
            }
            .task {
                await viewModel.loadNodePersons()
            }
            .refreshable {
                await viewModel.loadNodePersons()
            }
        }
    }

    private var nodePersonList: some View {
        List {
            // Worry Prompt Card at the top
            Section {
                WorryPromptCard()
            }

            // Grouped by type
            ForEach(viewModel.groupedByType, id: \.0) { type, persons in
                Section {
                    ForEach(persons) { person in
                        NavigationLink(destination: NodePersonDetailView(nodePerson: person)) {
                            NodePersonRow(nodePerson: person)
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: type.iconName)
                            .foregroundStyle(Color(hex: type.colorHex))
                        Text(type.label)
                            .font(.headline)
                        Spacer()
                        Text(type.whyCritical)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Node Person Row

struct NodePersonRow: View {
    let nodePerson: NodePerson

    var body: some View {
        HStack(spacing: 12) {
            // Type icon
            if let type = nodePerson.nodeTypeEnum {
                Image(systemName: type.iconName)
                    .font(.title2)
                    .foregroundStyle(Color(hex: type.colorHex))
                    .frame(width: 40, height: 40)
                    .background(Color(hex: type.colorHex).opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(nodePerson.name)
                    .font(.headline)

                HStack(spacing: 8) {
                    if let district = nodePerson.district {
                        Label(district, systemImage: "mappin")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let region = nodePerson.region {
                        Text(region)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Influence score
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(nodePerson.influenceScore))")
                    .font(.title3.bold())
                    .foregroundStyle(influenceColor)
                Text("影響力")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var influenceColor: Color {
        switch nodePerson.influenceScore {
        case 80...: return .green
        case 60..<80: return .blue
        case 40..<60: return .orange
        default: return .gray
        }
    }
}

import Foundation

/// ViewModel for the NodePerson list — shared across all platforms.
@Observable
final class NodePersonListViewModel {
    var nodePersons: [NodePerson] = []
    var isLoading = false
    var errorMessage: String?
    var selectedNodeType: NodeType?
    var selectedRegion: String?

    /// Filtered list based on current selections
    var filteredNodePersons: [NodePerson] {
        nodePersons.filter { np in
            if let type = selectedNodeType, np.nodeType != type.rawValue {
                return false
            }
            if let region = selectedRegion, np.region != region {
                return false
            }
            return true
        }
    }

    /// All unique regions from loaded data
    var availableRegions: [String] {
        Array(Set(nodePersons.compactMap(\.region))).sorted()
    }

    /// Grouped by node type for section display
    var groupedByType: [(NodeType, [NodePerson])] {
        let grouped = Dictionary(grouping: filteredNodePersons) { np in
            NodeType(rawValue: np.nodeType) ?? .opinionLeader
        }
        return NodeType.allCases.compactMap { type in
            guard let persons = grouped[type], !persons.isEmpty else { return nil }
            return (type, persons)
        }
    }

    func loadNodePersons() async {
        isLoading = true
        errorMessage = nil
        do {
            nodePersons = try await APIClient.shared.fetchNodePersons()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func clearFilters() {
        selectedNodeType = nil
        selectedRegion = nil
    }
}

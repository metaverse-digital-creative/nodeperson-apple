import Foundation

/// ViewModel for a single NodePerson detail view.
@Observable
final class NodePersonDetailViewModel {
    var nodePerson: NodePerson?
    var script: ConversationScript?
    var isLoading = false
    var errorMessage: String?

    private let nodePersonId: String

    init(nodePersonId: String) {
        self.nodePersonId = nodePersonId
    }

    /// Convenience init from existing NodePerson
    init(nodePerson: NodePerson) {
        self.nodePersonId = nodePerson.id
        self.nodePerson = nodePerson
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            async let fetchedPerson = APIClient.shared.fetchNodePerson(id: nodePersonId)
            nodePerson = try await fetchedPerson

            // Load the matching conversation script
            if let type = nodePerson?.nodeType {
                let scripts = try await APIClient.shared.fetchScripts(nodeType: type)
                script = scripts.first
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func recalculateInfluence() async {
        guard let id = nodePerson?.id else { return }
        do {
            let _: NodePerson = try await APIClient.shared.request(
                .recalculateInfluence(id: id)
            )
            await load() // Reload to get updated score
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

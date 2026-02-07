import Foundation

/// ViewModel for conversation scripts and the core principle.
@Observable
final class ScriptViewModel {
    var scripts: [ConversationScript] = []
    var corePrinciple: CorePrinciple?
    var isLoading = false
    var errorMessage: String?
    var filterNodeType: NodeType?

    var filteredScripts: [ConversationScript] {
        guard let filter = filterNodeType else { return scripts }
        return scripts.filter { $0.nodeType == filter.rawValue }
    }

    func loadAll() async {
        isLoading = true
        errorMessage = nil
        do {
            async let fetchedScripts = APIClient.shared.fetchScripts()
            async let fetchedPrinciple = APIClient.shared.fetchCorePrinciple()
            scripts = try await fetchedScripts
            corePrinciple = try await fetchedPrinciple
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

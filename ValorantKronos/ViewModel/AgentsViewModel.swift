import Foundation
import Combine

@MainActor
class AgentsViewModel: ObservableObject {
    @Published var agents: [Agent] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedRoleFilter: String = "ALL AGENTS"
    @Published var agentFilterOptions: [String: String] = ["ALL AGENTS": "ALL AGENTS"]

    var filteredAgents: [Agent] {
        if selectedRoleFilter == "ALL AGENTS" {
            return agents
        } else {
            return agentsByRole()[selectedRoleFilter] ?? []
        }
    }
    
    func loadAgents(forceRefresh: Bool = false) async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedAgents = try await Agent.fetchAgents(forceRefresh: forceRefresh)
            agents = fetchedAgents
            
            // Populate filter options from loaded agents
            let roles = self.agentsByRole().keys
            for role in roles {
                self.agentFilterOptions[role] = "\(role.uppercased())S"
            }
        } catch {
            errorMessage = "Failed to load agents: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    /// Groups agents by their role's display name.
    /// - Returns: A dictionary where keys are role display names and values are arrays of agents with that role.
    /// - If an agent has no role, it will be grouped under "Unknown".
    func agentsByRole() -> [String: [Agent]] {
        return Dictionary(grouping: agents) { $0.role?.displayName ?? "Unknown" }
    }
}

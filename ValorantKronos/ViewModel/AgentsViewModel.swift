//
//  AgentsViewModel.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/11/25.
//  Updated for Milestone 2: Hardened state machine, thread safety & edge-case filtering.
//

import Foundation
import Combine

// MARK: - StateManageableViewModel Protocol

@MainActor
public protocol StateManageableViewModel: ObservableObject {
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var isEmpty: Bool { get }
}

// MARK: - Error User-Friendly Message Extension

extension Error {
    /// Converts low-level errors into human-readable, user-friendly descriptions.
    public var userFriendlyMessage: String {
        if let apiError = self as? APIError {
            switch apiError {
            case .invalidURL:
                return "The server URL was invalid."
            case .requestFailed(let underlying):
                return underlying.userFriendlyMessage
            case .invalidResponse:
                return "The server returned an invalid response. Please try again later."
            case .decodingFailed(_):
                return "Unable to parse server data. Please ensure the app is up to date."
            case .noData:
                return "No data was returned from the server."
            }
        }

        if let urlError = self as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return "No internet connection. Please check your network and try again."
            case .timedOut:
                return "The request timed out. Please try again."
            case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
                return "Unable to connect to the server. Please check your connection."
            default:
                return urlError.localizedDescription
            }
        }

        if self is DecodingError {
            return "Unable to process the server data. Please try again later."
        }

        return localizedDescription
    }
}

// MARK: - AgentsViewModel Implementation

@MainActor
final class AgentsViewModel: ObservableObject, StateManageableViewModel {
    @Published var agents: [Agent] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedRoleFilter: String = "ALL AGENTS"
    @Published var agentFilterOptions: [String: String] = ["ALL AGENTS": "ALL AGENTS"]
    @Published var searchText: String = ""

    /// Returns `true` if the underlying agents collection is empty.
    var isEmpty: Bool {
        agents.isEmpty
    }

    /// Returns `true` if the filtered agents collection is empty.
    var isFilteredEmpty: Bool {
        filteredAgents.isEmpty
    }

    /// Returns `true` when agents are loaded but the active search/role filter yields zero results.
    var hasNoSearchResults: Bool {
        !agents.isEmpty && filteredAgents.isEmpty
    }

    /// Returns agents filtered by both `selectedRoleFilter` and `searchText`.
    /// Handles whitespace trimming, case-insensitivity, and empty strings gracefully.
    var filteredAgents: [Agent] {
        let trimmedFilter = selectedRoleFilter.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return agents.filter { agent in
            // 1. Role Filter Evaluation
            let matchesRole: Bool
            if trimmedFilter.isEmpty || trimmedFilter.caseInsensitiveCompare("ALL AGENTS") == .orderedSame {
                matchesRole = true
            } else {
                let roleName = agent.role?.displayName ?? "Unknown"
                matchesRole = roleName.caseInsensitiveCompare(trimmedFilter) == .orderedSame
            }

            // 2. Search Text Evaluation
            let matchesSearch: Bool
            if trimmedSearch.isEmpty {
                matchesSearch = true
            } else {
                matchesSearch = agent.displayName.localizedCaseInsensitiveContains(trimmedSearch)
            }

            return matchesRole && matchesSearch
        }
    }

    /// Fetches agents from API or cache, managing state transitions safely.
    func loadAgents(forceRefresh: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fetchedAgents = try await Agent.fetchAgents(forceRefresh: forceRefresh)
            agents = fetchedAgents

            // Atomically populate filter options
            let roles = self.agentsByRole().keys
            var options: [String: String] = ["ALL AGENTS": "ALL AGENTS"]
            for role in roles {
                options[role] = "\(role.uppercased())S"
            }
            self.agentFilterOptions = options
        } catch {
            errorMessage = "Failed to load agents: \(error.userFriendlyMessage)"
        }
    }

    /// Groups agents by their role's display name.
    /// - Returns: A dictionary where keys are role display names and values are arrays of agents with that role.
    /// - If an agent has no role, it will be grouped under "Unknown".
    func agentsByRole() -> [String: [Agent]] {
        return Dictionary(grouping: agents) { $0.role?.displayName ?? "Unknown" }
    }
}


//
//  SearchViewModel.swift
//  ValorantKronos
//
//  Created by Teamwork Agent on 12/09/26.
//  Universal search across Agents, Weapons, and Maps.
//

import Foundation
import Combine

// MARK: - Search Scope Enum

public enum SearchScope: String, CaseIterable, Identifiable, Sendable {
    case all = "all"
    case agents = "agents"
    case weapons = "weapons"
    case maps = "maps"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .all: return "All"
        case .agents: return "Agents"
        case .weapons: return "Weapons"
        case .maps: return "Maps"
        }
    }
    
    public init?(rawValue: String) {
        switch rawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "all": self = .all
        case "agents", "agent": self = .agents
        case "weapons", "weapon": self = .weapons
        case "maps", "map": self = .maps
        default: return nil
        }
    }
}

// MARK: - SearchViewModel Implementation

@MainActor
final class SearchViewModel: ObservableObject, StateManageableViewModel {
    
    // MARK: - Published Properties
    
    @Published var searchText: String = "" {
        didSet {
            filterResults()
        }
    }
    
    @Published var selectedScope: SearchScope = .all {
        didSet {
            filterResults()
        }
    }
    
    @Published private(set) var matchingAgents: [Agent] = []
    @Published private(set) var matchingWeapons: [Weapon] = []
    @Published private(set) var matchingMaps: [Map] = []
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    
    // MARK: - Master In-Memory Datasets
    
    private(set) var allAgents: [Agent] = []
    private(set) var allWeapons: [Weapon] = []
    private(set) var allMaps: [Map] = []
    
    // MARK: - Computed Properties
    
    /// Returns true if there are zero matching items in any category for the current query and scope.
    var isEmpty: Bool {
        matchingAgents.isEmpty && matchingWeapons.isEmpty && matchingMaps.isEmpty
    }
    
    /// Returns true if there is at least one matching item in any category.
    var hasResults: Bool {
        !isEmpty
    }
    
    /// Total count of matching items across all active scopes.
    var totalResultCount: Int {
        matchingAgents.count + matchingWeapons.count + matchingMaps.count
    }
    
    /// Returns true if the search query is blank.
    var isQueryEmpty: Bool {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Returns true if a search was performed, but no results were found.
    var noResultsFound: Bool {
        !isQueryEmpty && isEmpty
    }
    
    /// Returns true if any master data has been loaded into memory.
    var isDataLoaded: Bool {
        !allAgents.isEmpty || !allWeapons.isEmpty || !allMaps.isEmpty
    }
    
    // MARK: - Initializer
    
    init(
        agents: [Agent] = [],
        weapons: [Weapon] = [],
        maps: [Map] = []
    ) {
        self.allAgents = agents
        self.allWeapons = weapons
        self.allMaps = maps.filter { $0.displayIcon != nil }
        if !agents.isEmpty || !weapons.isEmpty || !maps.isEmpty {
            filterResults()
        }
    }
    
    // MARK: - Networking & Data Loading

    /// Loads agents, weapons, and maps.
    /// 1. Reads the disk cache synchronously — results appear instantly, no spinner.
    /// 2. If data is stale (>24h) or forceRefresh, fires a background network refresh.
    func loadAllData(forceRefresh: Bool = false) async {
        // --- Step 1: Instant cache read (no async, no spinner) ---
        if !forceRefresh && allAgents.isEmpty {
            if let cachedAgents: [Agent] = DataCache.shared.retrieve(forKey: "agents") {
                self.allAgents = cachedAgents
            }
            if let cachedWeapons: [Weapon] = DataCache.shared.retrieve(forKey: "weapons") {
                self.allWeapons = cachedWeapons
            }
            if let cachedMaps: [Map] = DataCache.shared.retrieve(forKey: "maps") {
                self.allMaps = cachedMaps.filter { $0.displayIcon != nil }
            }
            // Show cached results immediately
            if isDataLoaded { filterResults() }
        }

        // --- Step 2: Check if a network refresh is needed ---
        let cacheDuration: TimeInterval = 60 * 60 * 24
        let agentsCacheDate = DataCache.shared.cacheDate(forKey: "agents")
        let isStale = forceRefresh ||
            agentsCacheDate == nil ||
            Date().timeIntervalSince(agentsCacheDate!) > cacheDuration

        guard isStale else { return }

        // Show a subtle refresh indicator only when fetching (not a full-screen block)
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let agentsTask = Agent.fetchAgents(forceRefresh: true)
            async let weaponsTask = Weapon.fetchWeapons(forceRefresh: true)
            async let mapsTask = Map.fetchMaps(forceRefresh: true)

            let (fetchedAgents, fetchedWeapons, fetchedMaps) = try await (agentsTask, weaponsTask, mapsTask)

            self.allAgents = fetchedAgents
            self.allWeapons = fetchedWeapons
            self.allMaps = fetchedMaps.filter { $0.displayIcon != nil }
            self.filterResults()
        } catch {
            // Keep showing cached data — only surface an error if we have nothing at all
            if !isDataLoaded {
                self.errorMessage = "Failed to load search data: \(error.userFriendlyMessage)"
            }
        }
    }
    
    // MARK: - Filtering Logic
    
    /// Filters master datasets according to `searchText` and `selectedScope`.
    func filterResults() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Scope 1: Agents
        if selectedScope == .all || selectedScope == .agents {
            if query.isEmpty {
                matchingAgents = allAgents
            } else {
                matchingAgents = allAgents.filter { agent in
                    let matchesName = agent.displayName.localizedCaseInsensitiveContains(query)
                    let matchesRole = agent.role?.displayName?.localizedCaseInsensitiveContains(query) ?? false
                    return matchesName || matchesRole
                }
            }
        } else {
            matchingAgents = []
        }
        
        // Scope 2: Weapons
        if selectedScope == .all || selectedScope == .weapons {
            if query.isEmpty {
                matchingWeapons = allWeapons
            } else {
                matchingWeapons = allWeapons.filter { weapon in
                    let matchesName = weapon.displayName.localizedCaseInsensitiveContains(query)
                    let matchesCategory = weapon.category.localizedCaseInsensitiveContains(query)
                    return matchesName || matchesCategory
                }
            }
        } else {
            matchingWeapons = []
        }
        
        // Scope 3: Maps
        if selectedScope == .all || selectedScope == .maps {
            if query.isEmpty {
                matchingMaps = allMaps
            } else {
                matchingMaps = allMaps.filter { map in
                    map.displayName.localizedCaseInsensitiveContains(query)
                }
            }
        } else {
            matchingMaps = []
        }
    }
}

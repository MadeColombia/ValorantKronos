//
//  MapsViewModel.swift
//  ValorantKronos
//
//  Created by Ethan Montalvo on 17/06/25.
//  Updated for Milestone 2: Hardened state machine, thread safety & edge-case filtering.
//

import Foundation
import Combine

@MainActor
final class MapsViewModel: ObservableObject, StateManageableViewModel {
    @Published var maps: [Map] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""

    /// Returns `true` if the underlying maps collection is empty.
    var isEmpty: Bool {
        maps.isEmpty
    }

    /// Returns `true` if the filtered maps collection is empty.
    var isFilteredEmpty: Bool {
        filteredMaps.isEmpty
    }

    /// Returns `true` when maps are loaded but search yields no results.
    var hasNoSearchResults: Bool {
        !maps.isEmpty && filteredMaps.isEmpty
    }

    /// Returns maps filtered by `searchText`.
    /// Handles whitespace trimming and case-insensitivity cleanly.
    var filteredMaps: [Map] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedSearch.isEmpty {
            return maps
        } else {
            return maps.filter { $0.displayName.localizedCaseInsensitiveContains(trimmedSearch) }
        }
    }

    /// Fetches maps from API or cache, filtering out maps without display icons.
    func loadMaps(forceRefresh: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fetchedMaps = try await Map.fetchMaps(forceRefresh: forceRefresh)
            // Filter maps with display icons before updating published state
            self.maps = fetchedMaps.filter { $0.displayIcon != nil }
        } catch {
            errorMessage = "Failed to load maps: \(error.userFriendlyMessage)"
        }
    }

    /// Retains only maps with a valid display icon. Maintained for backwards compatibility.
    func filterMaps() {
        maps = maps.filter { $0.displayIcon != nil }
    }
}


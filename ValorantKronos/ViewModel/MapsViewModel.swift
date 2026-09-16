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
    @Published var nonBlockingAlertMessage: String? = nil
    @Published var searchText: String = ""

    private let repository: ValorantRepositoryProtocol
    private let service: APIServiceProtocol

    public init(
        maps: [Map]? = nil,
        repository: ValorantRepositoryProtocol = ValorantRepository.shared,
        service: APIServiceProtocol = APIService.shared
    ) {
        self.repository = repository
        self.service = service

        if let initialMaps = maps {
            self.maps = initialMaps.filter { $0.displayIcon != nil }
        } else {
            let stored = repository.fetchMapsFromStorage().filter { $0.displayIcon != nil }
            if !stored.isEmpty {
                self.maps = stored
            }
        }
    }

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

    /// Fetches maps from Core Data or API, filtering out maps without display icons.
    func loadMaps(forceRefresh: Bool = false) async {
        if !forceRefresh && !maps.isEmpty {
            return
        }

        if maps.isEmpty {
            let stored = repository.fetchMapsFromStorage().filter { $0.displayIcon != nil }
            if !stored.isEmpty {
                self.maps = stored
                if !forceRefresh { return }
            }
        }

        guard !isLoading else { return }
        if maps.isEmpty {
            isLoading = true
            errorMessage = nil
        }
        defer { isLoading = false }

        do {
            let fetchedMaps: [Map] = try await service.fetch(endpoint: "maps")
            try await repository.syncMaps(fetchedMaps)
            self.maps = fetchedMaps.filter { $0.displayIcon != nil }
            self.nonBlockingAlertMessage = nil
            self.errorMessage = nil
        } catch {
            if maps.isEmpty {
                errorMessage = "Failed to load maps: \(error.userFriendlyMessage)"
            } else {
                nonBlockingAlertMessage = "Unable to refresh maps: \(error.userFriendlyMessage)"
            }
        }
    }

    public func clearNonBlockingAlert() {
        nonBlockingAlertMessage = nil
    }

    /// Retains only maps with a valid display icon. Maintained for backwards compatibility.
    func filterMaps() {
        maps = maps.filter { $0.displayIcon != nil }
    }
}


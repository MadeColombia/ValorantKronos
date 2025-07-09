//
//  MapsViewModel.swift
//  ValorantKronos
//
//  Created by Ethan Montalvo on 17/06/25.
//

import Foundation

@MainActor
class MapsViewModel: ObservableObject {
    @Published var maps: [Map] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func loadMaps(forceRefresh: Bool = false) async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedMaps = try await Map.fetchMaps(forceRefresh: forceRefresh)
            maps = fetchedMaps
            filterMaps()
        } catch {
            errorMessage = "Failed to load maps: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func filterMaps() {
        maps = maps.filter { $0.displayIcon != nil }
    }
}

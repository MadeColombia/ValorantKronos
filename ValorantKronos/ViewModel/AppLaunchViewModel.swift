//
//  AppLaunchViewModel.swift
//  ValorantKronos
//
//  Created by Pair Programming Assistant on 15/09/26.
//  Orchestrates initial app startup, checking Core Data and bulk-preloading endpoints.
//

import Foundation
import Combine

@MainActor
public final class AppLaunchViewModel: ObservableObject {
    @Published public var isReady: Bool = false
    @Published public var statusMessage: String = "INITIALIZING CORE SYSTEMS..."
    @Published public var progress: Double = 0.0
    @Published public var errorMessage: String? = nil
    
    private let repository: ValorantRepositoryProtocol
    private let apiService: APIServiceProtocol
    
    public init(
        repository: ValorantRepositoryProtocol = ValorantRepository.shared,
        apiService: APIServiceProtocol = APIService.shared
    ) {
        self.repository = repository
        self.apiService = apiService
    }
    
    public func startInitialization() async {
        // 1. If Core Data already has data, launch UI immediately!
        if repository.hasInitialData() {
            isReady = true
            // Run silent background sync to keep data fresh without blocking user
            Task.detached(priority: .background) { [repository, apiService] in
                await Self.performBackgroundSync(repository: repository, apiService: apiService)
            }
            return
        }
        
        // 2. Cold launch / First install: bulk-load all endpoints concurrently
        statusMessage = "CONNECTING TO VALORANT PROTOCOL..."
        progress = 0.1
        errorMessage = nil
        
        do {
            async let agentsTask: [Agent] = apiService.fetch(endpoint: "agents", parameters: ["isPlayableCharacter": "true"])
            async let weaponsTask: [Weapon] = apiService.fetch(endpoint: "weapons", parameters: nil)
            async let mapsTask: [Map] = apiService.fetch(endpoint: "maps", parameters: nil)
            
            statusMessage = "DOWNLOADING ARSENAL & AGENTS..."
            progress = 0.4
            
            let (agents, weapons, maps) = try await (agentsTask, weaponsTask, mapsTask)
            
            statusMessage = "SAVING TO LOCAL DATABASE..."
            progress = 0.8
            
            try await repository.syncAgents(agents)
            try await repository.syncWeapons(weapons)
            try await repository.syncMaps(maps)
            
            progress = 1.0
            statusMessage = "READY"
            
            // Brief visual transition pause
            try? await Task.sleep(nanoseconds: 300_000_000)
            isReady = true
        } catch {
            print("Failed initial load: \(error)")
            if repository.hasInitialData() {
                isReady = true
            } else {
                errorMessage = "Failed to load game data: \(error.userFriendlyMessage)"
            }
        }
    }
    
    private static func performBackgroundSync(repository: ValorantRepositoryProtocol, apiService: APIServiceProtocol) async {
        do {
            async let agentsTask: [Agent] = apiService.fetch(endpoint: "agents", parameters: ["isPlayableCharacter": "true"])
            async let weaponsTask: [Weapon] = apiService.fetch(endpoint: "weapons", parameters: nil)
            async let mapsTask: [Map] = apiService.fetch(endpoint: "maps", parameters: nil)
            
            let (agents, weapons, maps) = try await (agentsTask, weaponsTask, mapsTask)
            try await repository.syncAgents(agents)
            try await repository.syncWeapons(weapons)
            try await repository.syncMaps(maps)
        } catch {
            print("Background sync failed: \(error)")
        }
    }
}

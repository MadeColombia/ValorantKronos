//
//  ValorantRepository.swift
//  ValorantKronos
//
//  Created by Pair Programming Assistant on 15/09/26.
//  Repository handling Core Data queries, smart diffing/upsert, and domain mapping.
//

import Foundation
import CoreData

// MARK: - ValorantRepositoryProtocol

public protocol ValorantRepositoryProtocol: AnyObject, Sendable {
    func fetchAgentsFromStorage() -> [Agent]
    func fetchWeaponsFromStorage() -> [Weapon]
    func fetchMapsFromStorage() -> [Map]
    
    @discardableResult
    func syncAgents(_ agents: [Agent]) async throws -> Bool
    
    @discardableResult
    func syncWeapons(_ weapons: [Weapon]) async throws -> Bool
    
    @discardableResult
    func syncMaps(_ maps: [Map]) async throws -> Bool
    
    func hasInitialData() -> Bool
    func clearAllData() async throws
}

// MARK: - ValorantRepository Implementation

public final class ValorantRepository: ValorantRepositoryProtocol, @unchecked Sendable {
    public static let shared = ValorantRepository()
    
    private let persistenceController: PersistenceController
    
    public init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }
    
    // MARK: - Local Reads
    
    public func fetchAgentsFromStorage() -> [Agent] {
        let context = persistenceController.viewContext
        var result: [Agent] = []
        context.performAndWait {
            let request = NSFetchRequest<AgentEntity>(entityName: "AgentEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "displayName", ascending: true)]
            
            do {
                let entities = try context.fetch(request)
                result = entities.map { $0.toDomainModel() }
            } catch {
                print("Failed to fetch agents from Core Data: \(error)")
            }
        }
        return result
    }
    
    public func fetchWeaponsFromStorage() -> [Weapon] {
        let context = persistenceController.viewContext
        var result: [Weapon] = []
        context.performAndWait {
            let request = NSFetchRequest<WeaponEntity>(entityName: "WeaponEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "displayName", ascending: true)]
            
            do {
                let entities = try context.fetch(request)
                result = entities.map { $0.toDomainModel() }
            } catch {
                print("Failed to fetch weapons from Core Data: \(error)")
            }
        }
        return result
    }
    
    public func fetchMapsFromStorage() -> [Map] {
        let context = persistenceController.viewContext
        var result: [Map] = []
        context.performAndWait {
            let request = NSFetchRequest<MapEntity>(entityName: "MapEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "displayName", ascending: true)]
            
            do {
                let entities = try context.fetch(request)
                result = entities.map { $0.toDomainModel() }
            } catch {
                print("Failed to fetch maps from Core Data: \(error)")
            }
        }
        return result
    }
    
    public func hasInitialData() -> Bool {
        let context = persistenceController.viewContext
        var hasData = false
        context.performAndWait {
            let agentReq = NSFetchRequest<AgentEntity>(entityName: "AgentEntity")
            let weaponReq = NSFetchRequest<WeaponEntity>(entityName: "WeaponEntity")
            let mapReq = NSFetchRequest<MapEntity>(entityName: "MapEntity")
            
            let agentCount = (try? context.count(for: agentReq)) ?? 0
            let weaponCount = (try? context.count(for: weaponReq)) ?? 0
            let mapCount = (try? context.count(for: mapReq)) ?? 0
            
            hasData = agentCount > 0 && weaponCount > 0 && mapCount > 0
        }
        return hasData
    }
    
    // MARK: - Smart Diff & Sync (Upsert & Prune)
    
    @discardableResult
    public func syncAgents(_ agents: [Agent]) async throws -> Bool {
        let context = persistenceController.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<AgentEntity>(entityName: "AgentEntity")
            let existingEntities = try context.fetch(request)
            var existingByUUID = Dictionary(uniqueKeysWithValues: existingEntities.map { ($0.uuid, $0) })
            
            var hasChanges = false
            
            for agent in agents {
                if let existing = existingByUUID.removeValue(forKey: agent.uuid) {
                    if existing.update(from: agent) {
                        hasChanges = true
                    }
                } else {
                    let newEntity = AgentEntity(context: context)
                    newEntity.uuid = agent.uuid
                    newEntity.update(from: agent)
                    hasChanges = true
                }
            }
            
            // Prune entities no longer returned by the API
            for (_, orphan) in existingByUUID {
                context.delete(orphan)
                hasChanges = true
            }
            
            if hasChanges && context.hasChanges {
                try context.save()
            }
            
            return hasChanges
        }
    }
    
    @discardableResult
    public func syncWeapons(_ weapons: [Weapon]) async throws -> Bool {
        let context = persistenceController.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<WeaponEntity>(entityName: "WeaponEntity")
            let existingEntities = try context.fetch(request)
            var existingByUUID = Dictionary(uniqueKeysWithValues: existingEntities.map { ($0.uuid, $0) })
            
            var hasChanges = false
            
            for weapon in weapons {
                if let existing = existingByUUID.removeValue(forKey: weapon.uuid) {
                    if existing.update(from: weapon) {
                        hasChanges = true
                    }
                } else {
                    let newEntity = WeaponEntity(context: context)
                    newEntity.uuid = weapon.uuid
                    newEntity.update(from: weapon)
                    hasChanges = true
                }
            }
            
            // Prune orphans
            for (_, orphan) in existingByUUID {
                context.delete(orphan)
                hasChanges = true
            }
            
            if hasChanges && context.hasChanges {
                try context.save()
            }
            
            return hasChanges
        }
    }
    
    @discardableResult
    public func syncMaps(_ maps: [Map]) async throws -> Bool {
        let context = persistenceController.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<MapEntity>(entityName: "MapEntity")
            let existingEntities = try context.fetch(request)
            var existingByUUID = Dictionary(uniqueKeysWithValues: existingEntities.map { ($0.uuid, $0) })
            
            var hasChanges = false
            
            for map in maps {
                if let existing = existingByUUID.removeValue(forKey: map.uuid) {
                    if existing.update(from: map) {
                        hasChanges = true
                    }
                } else {
                    let newEntity = MapEntity(context: context)
                    newEntity.uuid = map.uuid
                    newEntity.update(from: map)
                    hasChanges = true
                }
            }
            
            // Prune orphans
            for (_, orphan) in existingByUUID {
                context.delete(orphan)
                hasChanges = true
            }
            
            if hasChanges && context.hasChanges {
                try context.save()
            }
            
            return hasChanges
        }
    }
    
    public func clearAllData() async throws {
        let context = persistenceController.newBackgroundContext()
        try await context.perform {
            let entityNames = ["AgentEntity", "WeaponEntity", "MapEntity"]
            for name in entityNames {
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: name)
                let objects = try context.fetch(fetchRequest)
                for obj in objects {
                    context.delete(obj)
                }
            }
            if context.hasChanges {
                try context.save()
            }
        }
    }
}

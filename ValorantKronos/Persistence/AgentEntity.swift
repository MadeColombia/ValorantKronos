//
//  AgentEntity.swift
//  ValorantKronos
//
//  Created by Pair Programming Assistant on 15/09/26.
//

import Foundation
import CoreData

@objc(AgentEntity)
public class AgentEntity: NSManagedObject {
    @NSManaged public var uuid: String
    @NSManaged public var displayName: String?
    @NSManaged public var developerName: String?
    @NSManaged public var agentDescription: String?
    @NSManaged public var fullPortrait: String?
    @NSManaged public var background: String?
    @NSManaged public var isPlayableCharacter: Bool
    @NSManaged public var roleJSON: Data?
    @NSManaged public var abilitiesJSON: Data?
    @NSManaged public var payloadJSON: Data?
    @NSManaged public var updatedAt: Date?
    
    private static let deterministicEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()
    
    /// Converts this Core Data entity to a domain `Agent` instance.
    public func toDomainModel() -> Agent {
        if let payloadJSON = payloadJSON,
           let agent = try? JSONDecoder().decode(Agent.self, from: payloadJSON) {
            return agent
        }
        
        let role: Role?
        if let roleJSON = roleJSON {
            role = try? JSONDecoder().decode(Role.self, from: roleJSON)
        } else {
            role = nil
        }
        
        let abilities: [Ability]
        if let abilitiesJSON = abilitiesJSON {
            abilities = (try? JSONDecoder().decode([Ability].self, from: abilitiesJSON)) ?? []
        } else {
            abilities = []
        }
        
        return Agent(
            uuid: uuid,
            displayName: displayName ?? "",
            developerName: developerName,
            description: agentDescription ?? "",
            fullPortrait: fullPortrait,
            background: background,
            isPlayableCharacter: isPlayableCharacter,
            role: role,
            abilities: abilities
        )
    }
    
    /// Updates attributes from an incoming `Agent` domain model.
    /// Returns `true` if any field actually changed.
    @discardableResult
    public func update(from agent: Agent) -> Bool {
        var changed = false
        
        if self.displayName != agent.displayName {
            self.displayName = agent.displayName
            changed = true
        }
        if self.developerName != agent.developerName {
            self.developerName = agent.developerName
            changed = true
        }
        if self.agentDescription != agent.description {
            self.agentDescription = agent.description
            changed = true
        }
        if self.fullPortrait != agent.fullPortrait {
            self.fullPortrait = agent.fullPortrait
            changed = true
        }
        if self.background != agent.background {
            self.background = agent.background
            changed = true
        }
        let incomingPlayable = agent.isPlayableCharacter ?? false
        if self.isPlayableCharacter != incomingPlayable {
            self.isPlayableCharacter = incomingPlayable
            changed = true
        }
        
        let newRoleData = try? Self.deterministicEncoder.encode(agent.role)
        if self.roleJSON != newRoleData {
            self.roleJSON = newRoleData
            changed = true
        }
        
        let newAbilitiesData = try? Self.deterministicEncoder.encode(agent.abilities)
        if self.abilitiesJSON != newAbilitiesData {
            self.abilitiesJSON = newAbilitiesData
            changed = true
        }
        
        if self.payloadJSON == nil {
            changed = true
        }
        
        if changed {
            self.payloadJSON = try? Self.deterministicEncoder.encode(agent)
            self.updatedAt = Date()
        }
        
        return changed
    }
}

//
//  Agent.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/13/25.
//

import Foundation

class Agent: Codable, Identifiable {
    
    var uuid: String
    var displayName: String
    
    var description: String
    
    var fullPortrait: String?
    var background: String?
    
    var isPlayableCharacter: Bool? = false
    
    var role: Role?
    var abilities: [Ability]
    
    init(uuid: String, displayName: String, description: String, fullPortrait: String?, background: String?, isPlayableCharacter: Bool?, role: Role?, abilities: [Ability]) {
        self.uuid = uuid
        self.displayName = displayName
        self.description = description
        self.fullPortrait = fullPortrait
        self.background = background
        self.role = role
        self.abilities = abilities
    }
    
}

class Role: Codable, Identifiable {
    
    var id: String?
    var displayName: String?
    
    var description: String?
    
    var displayIcon: String?
    
    init(id: String? = nil, displayName: String? = nil, description: String? = nil, displayIcon: String? = nil) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.displayIcon = displayIcon
    }
}

class Ability: Codable, Identifiable {
    
    var slot: String
    var displayName: String
    
    var description: String
    
    var displayIcon: String?
    
    init(slot: String, displayName: String, description: String, displayIcon: String? = nil) {
        self.slot = slot
        self.displayName = displayName
        self.description = description
        self.displayIcon = displayIcon
    }
}


// MARK: - Mock Data

let mockAgent = Agent(
    uuid: "309402333",
    displayName: "SOVA",
    description: """
    Born from the eternal winter of Russia's tundra, Sova tracks, finds, and eliminates \
    enemies with ruthless efficiency and precision. His custom bow and incredible scouting abilities \
    ensure that even if you run, you cannot hide.
    """,
    fullPortrait: "https://media.valorant-api.com/agents/320b2a48-4d9b-a075-30f1-1f93a9b638fa/fullportrait.png",
    background: "https://media.valorant-api.com/agents/320b2a48-4d9b-a075-30f1-1f93a9b638fa/background.png",
    isPlayableCharacter: true,
    role: Role(
        id: "1b47567f-8f7b-444b-aae3-b0c634622d10",
        displayName: "Initiator",
        description: """
        Initiators challenge angles by setting up their team to enter contested ground \
        and push defenders away.
        """,
        displayIcon: "https://media.valorant-api.com/agents/roles/1b47567f-8f7b-444b-aae3-b0c634622d10/displayicon.png"
    ),
    abilities: [
        Ability(
            slot: "Ability1",
            displayName: "Shock Bolt",
            description: """
            EQUIP a bow with a shock bolt. FIRE to send the explosive bolt forward, detonating \
            upon collision and damaging players nearby. HOLD FIRE to extend the range of the projectile. \
            ALT FIRE to add up to two bounces to this arrow.
            """,
            displayIcon: "https://media.valorant-api.com/agents/320b2a48-4d9b-a075-30f1-1f93a9b638fa/abilities/ability1/displayicon.png"
        ),
        Ability(
            slot: "Ability2",
            displayName: "Recon Bolt",
            description: """
            EQUIP a bow with recon bolt. FIRE to send the recon bolt forward, activating upon \
            collision and Revealing the location of nearby enemies caught in the line of sight of the bolt. \
            Enemies can destroy this bolt. HOLD FIRE to extend the range of the projectile. ALT FIRE to add \
            up to two bounces to this arrow.
            """,
            displayIcon: "https://media.valorant-api.com/agents/320b2a48-4d9b-a075-30f1-1f93a9b638fa/abilities/ability2/displayicon.png"
        ),
        Ability(
            slot: "Grenade",
            displayName: "Owl Drone",
            description: """
            EQUIP an owl drone. FIRE to deploy and take control of movement of the drone. \
            While in control of the drone, FIRE to shoot a marking dart. This dart will Reveal the location of any \
            player struck by the dart. Enemies can destroy the Owl Drone.
            """,
            displayIcon: "https://media.valorant-api.com/agents/320b2a48-4d9b-a075-30f1-1f93a9b638fa/abilities/grenade/displayicon.png"
        ),
        Ability(
            slot: "Ultimate",
            displayName: "Hunter's Fury",
            description: """
            EQUIP a bow with three long-range, wall-piercing energy blasts. FIRE to release an energy \
            blast in a line in front of Sova, dealing damage and Revealing the location of enemies caught in the line. \
            This ability can be RE-USED up to two more times while the ability timer is active.
            """,
            displayIcon: "https://media.valorant-api.com/agents/320b2a48-4d9b-a075-30f1-1f93a9b638fa/abilities/ultimate/displayicon.png"
        ),
        Ability(
            slot: "Passive",
            displayName: "Uncanny Marksman",
            description: """
            Sova's custom bow can fire his arrows and bounce them off terrain. Holding fire charges the bow's power, \
            and the bolt is loosed when released. Press alt fire to change the number of bounces.Your arrows can bounce \
            off terrain. Holding left click increases the bow's range trajectory. Right clicking Toggle through the desired \
            number of terrain bounces by right clicking. The arrow is loosed when left click is released.
            """,
            displayIcon: ""
        )
    ]
)

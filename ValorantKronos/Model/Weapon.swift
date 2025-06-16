//
//  Weapon.swift
//  ValorantKronos
//
//  Created by Ethan Montalvo on 3/04/25.
//

import Foundation

class Weapon: Codable, Identifiable {
    
    let uuid: String
    let displayName: String
    
    let category: String
    
    let defaultSkinUuid: String
    let displayIcon: String?
    let killStreamIcon: String?
    
    var weaponStats: stats
    var weaponSkins: [skins]
    
    init(uuid: String, displayName: String, category: String, defaultSkinUuid: String, displayIcon: String? = nil, killStreamIcon: String? = nil, weaponStats: stats, weaponSkins: [skins]) {
        self.uuid = uuid
        self.displayName = displayName
        self.category = category
        self.defaultSkinUuid = defaultSkinUuid
        self.displayIcon = displayIcon
        self.killStreamIcon = killStreamIcon
        self.weaponStats = weaponStats
        self.weaponSkins = weaponSkins
    }
}

class stats: Codable, Identifiable {
    
    let fireRate: Int
    let magazineSize: Int
    let runSpeedMultiplier: Double
    let equipTimeSeconds: Double
    let reloadTimeSeconds: Double
    
    var damageRanges: damageRanges
    
    init(fireRate: Int, magazineSize: Int, runSpeedMultiplier: Double, equipTimeSeconds: Double, reloadTimeSeconds: Double, damageRanges: damageRanges) {
        self.fireRate = fireRate
        self.magazineSize = magazineSize
        self.runSpeedMultiplier = runSpeedMultiplier
        self.equipTimeSeconds = equipTimeSeconds
        self.reloadTimeSeconds = reloadTimeSeconds
        self.damageRanges = damageRanges
    }
}

class damageRanges: Codable, Identifiable {
    
    let rangeStartMeters: Double
    let rangeEndMeters: Double
    let headDamage: Double
    let bodyDamage: Double
    let legDamage: Double
    
    init(rangeStartMeters: Double, rangeEndMeters: Double, headDamage: Double, bodyDamage: Double, legDamage: Double) {
        self.rangeStartMeters = rangeStartMeters
        self.rangeEndMeters = rangeEndMeters
        self.headDamage = headDamage
        self.bodyDamage = bodyDamage
        self.legDamage = legDamage
    }
}

class skins: Codable, Identifiable {
    
    let uuid: String
    let displayName: String?
    
    let displayIcon: String?
    let wallpaper: String?
    let contentTierUuid: String?
    
    var chromas: [chroma?]
    
    init(uuid: String, displayName: String?, displayIcon: String?, wallpaper: String?, contentTierUuid: String?, chromas: [chroma?]) {
        self.uuid = uuid
        self.displayName = displayName
        self.displayIcon = displayIcon
        self.wallpaper = wallpaper
        self.contentTierUuid = contentTierUuid
        self.chromas = chromas
    }
}

class chroma: Codable, Identifiable {
    
    let uuid: String
    let displayName: String?
    
    let displayIcon: String?
    let fullRender: String?
    let swatch: String?
    
    init(uuid: String, displayName: String?, displayIcon: String?, fullRender: String?, swatch: String?) {
        self.uuid = uuid
        self.displayName = displayName
        self.displayIcon = displayIcon
        self.fullRender = fullRender
        self.swatch = swatch
    }
}


// MARK: - Mock Data

let mockWeapon = Weapon(uuid: "63e6c2b6-4a8e-869c-3d4c-e38355226584", displayName: "Odin", category: "Heavy", defaultSkinUuid: "f454efd1-49cb-372f-7096-d394df615308", displayIcon: "https://media.valorant-api.com/weapons/63e6c2b6-4a8e-869c-3d4c-e38355226584/displayicon.png", killStreamIcon:  "https://media.valorant-api.com/weapons/63e6c2b6-4a8e-869c-3d4c-e38355226584/killstreamicon.png", weaponStats: stats(fireRate: 12, magazineSize: 100, runSpeedMultiplier: 0.76, equipTimeSeconds: 1.25, reloadTimeSeconds: 5, damageRanges: damageRanges(rangeStartMeters: 0, rangeEndMeters: 30, headDamage: 95, bodyDamage: 38, legDamage: 32.3)), weaponSkins: [skins(uuid: "89be9866-4807-6235-2a95-499cd23828df", displayName: "Altitude Odin", displayIcon: "https://media.valorant-api.com/weaponskins/89be9866-4807-6235-2a95-499cd23828df/displayicon.png", wallpaper: "", contentTierUuid: "0cebb8be-46d7-c12a-d306-e9907bfc5a25", chromas: [chroma(uuid: "092a25a4-422f-f577-37ac-26a5d489c155", displayName: "Altitude Odin", displayIcon: "", fullRender: "https://media.valorant-api.com/weaponskinchromas/092a25a4-422f-f577-37ac-26a5d489c155/fullrender.png", swatch: "")])])

//
//  WeaponEntity.swift
//  ValorantKronos
//
//  Created by Pair Programming Assistant on 15/09/26.
//

import Foundation
import CoreData

@objc(WeaponEntity)
public class WeaponEntity: NSManagedObject {
    @NSManaged public var uuid: String
    @NSManaged public var displayName: String?
    @NSManaged public var category: String?
    @NSManaged public var displayIcon: String?
    @NSManaged public var weaponStatsJSON: Data?
    @NSManaged public var shopDataJSON: Data?
    @NSManaged public var skinsJSON: Data?
    @NSManaged public var payloadJSON: Data?
    @NSManaged public var updatedAt: Date?
    
    private static let deterministicEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()
    
    /// Converts this Core Data entity to a domain `Weapon` instance.
    public func toDomainModel() -> Weapon {
        if let payloadJSON = payloadJSON,
           let weapon = try? JSONDecoder().decode(Weapon.self, from: payloadJSON) {
            return weapon
        }
        
        let stats: WeaponStats? = weaponStatsJSON.flatMap { try? JSONDecoder().decode(WeaponStats.self, from: $0) }
        let shop: ShopData? = shopDataJSON.flatMap { try? JSONDecoder().decode(ShopData.self, from: $0) }
        let skins: [WeaponSkin]? = skinsJSON.flatMap { try? JSONDecoder().decode([WeaponSkin].self, from: $0) }
        
        return Weapon(
            uuid: uuid,
            displayName: displayName ?? "",
            category: category ?? "",
            displayIcon: displayIcon,
            weaponStats: stats,
            shopData: shop,
            skins: skins
        )
    }
    
    /// Updates attributes from an incoming `Weapon` domain model.
    /// Returns `true` if any field actually changed.
    @discardableResult
    public func update(from weapon: Weapon) -> Bool {
        var changed = false
        
        if self.displayName != weapon.displayName {
            self.displayName = weapon.displayName
            changed = true
        }
        if self.category != weapon.category {
            self.category = weapon.category
            changed = true
        }
        if self.displayIcon != weapon.displayIcon {
            self.displayIcon = weapon.displayIcon
            changed = true
        }
        
        let newStatsData = try? Self.deterministicEncoder.encode(weapon.weaponStats)
        if self.weaponStatsJSON != newStatsData {
            self.weaponStatsJSON = newStatsData
            changed = true
        }
        
        let newShopData = try? Self.deterministicEncoder.encode(weapon.shopData)
        if self.shopDataJSON != newShopData {
            self.shopDataJSON = newShopData
            changed = true
        }
        
        let newSkinsData = try? Self.deterministicEncoder.encode(weapon.skins)
        if self.skinsJSON != newSkinsData {
            self.skinsJSON = newSkinsData
            changed = true
        }
        
        if self.payloadJSON == nil {
            changed = true
        }
        
        if changed {
            self.payloadJSON = try? Self.deterministicEncoder.encode(weapon)
            self.updatedAt = Date()
        }
        
        return changed
    }
}

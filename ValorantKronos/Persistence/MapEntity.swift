//
//  MapEntity.swift
//  ValorantKronos
//
//  Created by Pair Programming Assistant on 15/09/26.
//

import Foundation
import CoreData

@objc(MapEntity)
public class MapEntity: NSManagedObject {
    @NSManaged public var uuid: String
    @NSManaged public var displayName: String?
    @NSManaged public var coordinates: String?
    @NSManaged public var displayIcon: String?
    @NSManaged public var listViewIconTall: String?
    @NSManaged public var splash: String?
    @NSManaged public var premierBackgroundImage: String?
    @NSManaged public var payloadJSON: Data?
    @NSManaged public var updatedAt: Date?
    
    private static let deterministicEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()
    
    /// Converts this Core Data entity to a domain `Map` instance.
    public func toDomainModel() -> Map {
        if let payloadJSON = payloadJSON,
           let map = try? JSONDecoder().decode(Map.self, from: payloadJSON) {
            return map
        }
        
        return Map(
            uuid: uuid,
            displayName: displayName ?? "",
            coordinates: coordinates,
            displayIcon: displayIcon,
            listViewIconTall: listViewIconTall,
            splash: splash,
            premierBackgroundImage: premierBackgroundImage
        )
    }
    
    /// Updates attributes from an incoming `Map` domain model.
    /// Returns `true` if any field actually changed.
    @discardableResult
    public func update(from map: Map) -> Bool {
        var changed = false
        
        if self.displayName != map.displayName {
            self.displayName = map.displayName
            changed = true
        }
        if self.coordinates != map.coordinates {
            self.coordinates = map.coordinates
            changed = true
        }
        if self.displayIcon != map.displayIcon {
            self.displayIcon = map.displayIcon
            changed = true
        }
        if self.listViewIconTall != map.listViewIconTall {
            self.listViewIconTall = map.listViewIconTall
            changed = true
        }
        if self.splash != map.splash {
            self.splash = map.splash
            changed = true
        }
        if self.premierBackgroundImage != map.premierBackgroundImage {
            self.premierBackgroundImage = map.premierBackgroundImage
            changed = true
        }
        
        if self.payloadJSON == nil {
            changed = true
        }
        
        if changed {
            self.payloadJSON = try? Self.deterministicEncoder.encode(map)
            self.updatedAt = Date()
        }
        
        return changed
    }
}

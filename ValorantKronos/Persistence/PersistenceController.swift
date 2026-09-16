//
//  PersistenceController.swift
//  ValorantKronos
//
//  Created by Pair Programming Assistant on 15/09/26.
//  Core Data persistence stack supporting in-memory and disk stores with background sync.
//

import Foundation
import CoreData

public final class PersistenceController {
    public static let shared = PersistenceController()
    
    /// Static preview/test instance using in-memory store.
    public static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        return controller
    }()
    
    public let container: NSPersistentContainer
    
    public var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    public init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ValorantKronos", managedObjectModel: Self.sharedModel)
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    /// Creates a background context for executing heavy tasks (e.g. network payload decoding, diffing, and saving).
    public func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    /// Cached singleton NSManagedObjectModel to avoid multiple entity description warnings.
    public static let sharedModel: NSManagedObjectModel = {
        let bundles = [Bundle.main, Bundle(for: PersistenceController.self)]
        for bundle in bundles {
            if let modelURL = bundle.url(forResource: "ValorantKronos", withExtension: "momd"),
               let model = NSManagedObjectModel(contentsOf: modelURL) {
                return model
            }
        }
        return buildProgrammaticModel()
    }()
    
    private static func buildProgrammaticModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // --- AgentEntity ---
        let agentEntity = NSEntityDescription()
        agentEntity.name = "AgentEntity"
        agentEntity.managedObjectClassName = NSStringFromClass(AgentEntity.self)
        
        let agentUuid = NSAttributeDescription()
        agentUuid.name = "uuid"
        agentUuid.attributeType = .stringAttributeType
        agentUuid.isOptional = false
        agentUuid.isIndexed = true
        
        let agentDisplayName = NSAttributeDescription()
        agentDisplayName.name = "displayName"
        agentDisplayName.attributeType = .stringAttributeType
        agentDisplayName.isOptional = true
        
        let agentDeveloperName = NSAttributeDescription()
        agentDeveloperName.name = "developerName"
        agentDeveloperName.attributeType = .stringAttributeType
        agentDeveloperName.isOptional = true
        
        let agentDescription = NSAttributeDescription()
        agentDescription.name = "agentDescription"
        agentDescription.attributeType = .stringAttributeType
        agentDescription.isOptional = true
        
        let agentFullPortrait = NSAttributeDescription()
        agentFullPortrait.name = "fullPortrait"
        agentFullPortrait.attributeType = .stringAttributeType
        agentFullPortrait.isOptional = true
        
        let agentBackground = NSAttributeDescription()
        agentBackground.name = "background"
        agentBackground.attributeType = .stringAttributeType
        agentBackground.isOptional = true
        
        let agentIsPlayable = NSAttributeDescription()
        agentIsPlayable.name = "isPlayableCharacter"
        agentIsPlayable.attributeType = .booleanAttributeType
        agentIsPlayable.defaultValue = false
        
        let agentRoleJSON = NSAttributeDescription()
        agentRoleJSON.name = "roleJSON"
        agentRoleJSON.attributeType = .binaryDataAttributeType
        agentRoleJSON.isOptional = true
        
        let agentAbilitiesJSON = NSAttributeDescription()
        agentAbilitiesJSON.name = "abilitiesJSON"
        agentAbilitiesJSON.attributeType = .binaryDataAttributeType
        agentAbilitiesJSON.isOptional = true
        
        let agentUpdatedAt = NSAttributeDescription()
        agentUpdatedAt.name = "updatedAt"
        agentUpdatedAt.attributeType = .dateAttributeType
        agentUpdatedAt.isOptional = true
        
        let agentPayloadJSON = NSAttributeDescription()
        agentPayloadJSON.name = "payloadJSON"
        agentPayloadJSON.attributeType = .binaryDataAttributeType
        agentPayloadJSON.isOptional = true
        
        agentEntity.properties = [
            agentUuid, agentDisplayName, agentDeveloperName, agentDescription,
            agentFullPortrait, agentBackground, agentIsPlayable, agentRoleJSON,
            agentAbilitiesJSON, agentPayloadJSON, agentUpdatedAt
        ]
        
        // --- WeaponEntity ---
        let weaponEntity = NSEntityDescription()
        weaponEntity.name = "WeaponEntity"
        weaponEntity.managedObjectClassName = NSStringFromClass(WeaponEntity.self)
        
        let weaponUuid = NSAttributeDescription()
        weaponUuid.name = "uuid"
        weaponUuid.attributeType = .stringAttributeType
        weaponUuid.isOptional = false
        weaponUuid.isIndexed = true
        
        let weaponDisplayName = NSAttributeDescription()
        weaponDisplayName.name = "displayName"
        weaponDisplayName.attributeType = .stringAttributeType
        weaponDisplayName.isOptional = true
        
        let weaponCategory = NSAttributeDescription()
        weaponCategory.name = "category"
        weaponCategory.attributeType = .stringAttributeType
        weaponCategory.isOptional = true
        
        let weaponDisplayIcon = NSAttributeDescription()
        weaponDisplayIcon.name = "displayIcon"
        weaponDisplayIcon.attributeType = .stringAttributeType
        weaponDisplayIcon.isOptional = true
        
        let weaponStatsJSON = NSAttributeDescription()
        weaponStatsJSON.name = "weaponStatsJSON"
        weaponStatsJSON.attributeType = .binaryDataAttributeType
        weaponStatsJSON.isOptional = true
        
        let weaponShopDataJSON = NSAttributeDescription()
        weaponShopDataJSON.name = "shopDataJSON"
        weaponShopDataJSON.attributeType = .binaryDataAttributeType
        weaponShopDataJSON.isOptional = true
        
        let weaponSkinsJSON = NSAttributeDescription()
        weaponSkinsJSON.name = "skinsJSON"
        weaponSkinsJSON.attributeType = .binaryDataAttributeType
        weaponSkinsJSON.isOptional = true
        
        let weaponPayloadJSON = NSAttributeDescription()
        weaponPayloadJSON.name = "payloadJSON"
        weaponPayloadJSON.attributeType = .binaryDataAttributeType
        weaponPayloadJSON.isOptional = true
        
        let weaponUpdatedAt = NSAttributeDescription()
        weaponUpdatedAt.name = "updatedAt"
        weaponUpdatedAt.attributeType = .dateAttributeType
        weaponUpdatedAt.isOptional = true
        
        weaponEntity.properties = [
            weaponUuid, weaponDisplayName, weaponCategory, weaponDisplayIcon,
            weaponStatsJSON, weaponShopDataJSON, weaponSkinsJSON, weaponPayloadJSON, weaponUpdatedAt
        ]
        
        // --- MapEntity ---
        let mapEntity = NSEntityDescription()
        mapEntity.name = "MapEntity"
        mapEntity.managedObjectClassName = NSStringFromClass(MapEntity.self)
        
        let mapUuid = NSAttributeDescription()
        mapUuid.name = "uuid"
        mapUuid.attributeType = .stringAttributeType
        mapUuid.isOptional = false
        mapUuid.isIndexed = true
        
        let mapDisplayName = NSAttributeDescription()
        mapDisplayName.name = "displayName"
        mapDisplayName.attributeType = .stringAttributeType
        mapDisplayName.isOptional = true
        
        let mapCoordinates = NSAttributeDescription()
        mapCoordinates.name = "coordinates"
        mapCoordinates.attributeType = .stringAttributeType
        mapCoordinates.isOptional = true
        
        let mapDisplayIcon = NSAttributeDescription()
        mapDisplayIcon.name = "displayIcon"
        mapDisplayIcon.attributeType = .stringAttributeType
        mapDisplayIcon.isOptional = true
        
        let mapListViewIconTall = NSAttributeDescription()
        mapListViewIconTall.name = "listViewIconTall"
        mapListViewIconTall.attributeType = .stringAttributeType
        mapListViewIconTall.isOptional = true
        
        let mapSplash = NSAttributeDescription()
        mapSplash.name = "splash"
        mapSplash.attributeType = .stringAttributeType
        mapSplash.isOptional = true
        
        let mapPremierBg = NSAttributeDescription()
        mapPremierBg.name = "premierBackgroundImage"
        mapPremierBg.attributeType = .stringAttributeType
        mapPremierBg.isOptional = true
        
        let mapPayloadJSON = NSAttributeDescription()
        mapPayloadJSON.name = "payloadJSON"
        mapPayloadJSON.attributeType = .binaryDataAttributeType
        mapPayloadJSON.isOptional = true
        
        let mapUpdatedAt = NSAttributeDescription()
        mapUpdatedAt.name = "updatedAt"
        mapUpdatedAt.attributeType = .dateAttributeType
        mapUpdatedAt.isOptional = true
        
        mapEntity.properties = [
            mapUuid, mapDisplayName, mapCoordinates, mapDisplayIcon,
            mapListViewIconTall, mapSplash, mapPremierBg, mapPayloadJSON, mapUpdatedAt
        ]
        
        model.entities = [agentEntity, weaponEntity, mapEntity]
        return model
    }
}

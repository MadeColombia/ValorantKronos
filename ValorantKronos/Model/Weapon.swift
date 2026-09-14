//
//  Weapon.swift
//  ValorantKronos
//
//  Created by Ethan Montalvo on 3/04/25.
//

import Foundation

// MARK: - Weapon Model

public struct Weapon: Codable, Identifiable, Hashable, Sendable {
    public let uuid: String
    public var id: String { uuid }
    public let displayName: String
    public let category: String
    public let defaultSkinUuid: String?
    public let displayIcon: String?
    public let killStreamIcon: String?
    public let assetPath: String?
    public let weaponStats: WeaponStats?
    public let shopData: ShopData?
    public let skins: [WeaponSkin]?
    
    // MARK: - Backward Compatibility & Convenience
    
    public var weaponSkins: [WeaponSkin] {
        skins ?? []
    }
    
    /// Normalizes raw category string (e.g. "EEquippableCategory::Heavy" -> "Heavy")
    public var formattedCategory: String {
        if let range = category.range(of: "::") {
            return String(category[range.upperBound...])
        }
        return category
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case displayName
        case category
        case defaultSkinUuid
        case displayIcon
        case killStreamIcon
        case assetPath
        case weaponStats
        case shopData
        case skins
    }
    
    public init(
        uuid: String,
        displayName: String,
        category: String,
        defaultSkinUuid: String? = nil,
        displayIcon: String? = nil,
        killStreamIcon: String? = nil,
        assetPath: String? = nil,
        weaponStats: WeaponStats? = nil,
        shopData: ShopData? = nil,
        skins: [WeaponSkin]? = nil
    ) {
        self.uuid = uuid
        self.displayName = displayName
        self.category = category
        self.defaultSkinUuid = defaultSkinUuid
        self.displayIcon = displayIcon
        self.killStreamIcon = killStreamIcon
        self.assetPath = assetPath
        self.weaponStats = weaponStats
        self.shopData = shopData
        self.skins = skins
    }
    
    // Legacy initializer for backward compatibility
    public init(
        uuid: String,
        displayName: String,
        category: String,
        defaultSkinUuid: String,
        displayIcon: String? = nil,
        killStreamIcon: String? = nil,
        weaponStats: WeaponStats?,
        weaponSkins: [WeaponSkin]
    ) {
        self.init(
            uuid: uuid,
            displayName: displayName,
            category: category,
            defaultSkinUuid: defaultSkinUuid,
            displayIcon: displayIcon,
            killStreamIcon: killStreamIcon,
            assetPath: nil,
            weaponStats: weaponStats,
            shopData: nil,
            skins: weaponSkins
        )
    }
}

// MARK: - Weapon Stats

public struct WeaponStats: Codable, Hashable, Sendable {
    public let fireRate: Double
    public let magazineSize: Int
    public let runSpeedMultiplier: Double
    public let equipTimeSeconds: Double
    public let reloadTimeSeconds: Double
    public let firstBulletAccuracy: Double
    public let shotgunPelletCount: Int
    public let wallPenetration: String
    public let feature: String?
    public let fireMode: String?
    public let altFireType: String?
    public let adsStats: AdsStats?
    public let altShotgunStats: AltShotgunStats?
    public let airBurstStats: AirBurstStats?
    public let damageRanges: [DamageRange]
    
    public var formattedWallPenetration: String {
        if let range = wallPenetration.range(of: "::") {
            return String(wallPenetration[range.upperBound...])
        }
        return wallPenetration
    }
    
    public init(
        fireRate: Double,
        magazineSize: Int,
        runSpeedMultiplier: Double,
        equipTimeSeconds: Double,
        reloadTimeSeconds: Double,
        firstBulletAccuracy: Double = 0.8,
        shotgunPelletCount: Int = 1,
        wallPenetration: String = "EWallPenetrationDisplayType::Medium",
        feature: String? = nil,
        fireMode: String? = nil,
        altFireType: String? = nil,
        adsStats: AdsStats? = nil,
        altShotgunStats: AltShotgunStats? = nil,
        airBurstStats: AirBurstStats? = nil,
        damageRanges: [DamageRange] = []
    ) {
        self.fireRate = fireRate
        self.magazineSize = magazineSize
        self.runSpeedMultiplier = runSpeedMultiplier
        self.equipTimeSeconds = equipTimeSeconds
        self.reloadTimeSeconds = reloadTimeSeconds
        self.firstBulletAccuracy = firstBulletAccuracy
        self.shotgunPelletCount = shotgunPelletCount
        self.wallPenetration = wallPenetration
        self.feature = feature
        self.fireMode = fireMode
        self.altFireType = altFireType
        self.adsStats = adsStats
        self.altShotgunStats = altShotgunStats
        self.airBurstStats = airBurstStats
        self.damageRanges = damageRanges
    }
    
    // Legacy initializer for single damage range
    public init(
        fireRate: Double,
        magazineSize: Int,
        runSpeedMultiplier: Double,
        equipTimeSeconds: Double,
        reloadTimeSeconds: Double,
        damageRanges: DamageRange
    ) {
        self.init(
            fireRate: fireRate,
            magazineSize: magazineSize,
            runSpeedMultiplier: runSpeedMultiplier,
            equipTimeSeconds: equipTimeSeconds,
            reloadTimeSeconds: reloadTimeSeconds,
            firstBulletAccuracy: 0.8,
            shotgunPelletCount: 1,
            wallPenetration: "EWallPenetrationDisplayType::Medium",
            damageRanges: [damageRanges]
        )
    }
    
    public init(
        fireRate: Int,
        magazineSize: Int,
        runSpeedMultiplier: Double,
        equipTimeSeconds: Double,
        reloadTimeSeconds: Double,
        damageRanges: DamageRange
    ) {
        self.init(
            fireRate: Double(fireRate),
            magazineSize: magazineSize,
            runSpeedMultiplier: runSpeedMultiplier,
            equipTimeSeconds: equipTimeSeconds,
            reloadTimeSeconds: reloadTimeSeconds,
            damageRanges: damageRanges
        )
    }
}

// MARK: - Damage Range

public struct DamageRange: Codable, Hashable, Identifiable, Sendable {
    public var id: String { "\(rangeStartMeters)-\(rangeEndMeters)" }
    public let rangeStartMeters: Double
    public let rangeEndMeters: Double
    public let headDamage: Double
    public let bodyDamage: Double
    public let legDamage: Double
    
    public var startMetersInt: Int { Int(rangeStartMeters) }
    public var endMetersInt: Int { Int(rangeEndMeters) }
    
    public init(
        rangeStartMeters: Double,
        rangeEndMeters: Double,
        headDamage: Double,
        bodyDamage: Double,
        legDamage: Double
    ) {
        self.rangeStartMeters = rangeStartMeters
        self.rangeEndMeters = rangeEndMeters
        self.headDamage = headDamage
        self.bodyDamage = bodyDamage
        self.legDamage = legDamage
    }
    
    public init(
        rangeStartMeters: Int,
        rangeEndMeters: Int,
        headDamage: Double,
        bodyDamage: Double,
        legDamage: Double
    ) {
        self.rangeStartMeters = Double(rangeStartMeters)
        self.rangeEndMeters = Double(rangeEndMeters)
        self.headDamage = headDamage
        self.bodyDamage = bodyDamage
        self.legDamage = legDamage
    }
}

// MARK: - ADS & Alternate Fire Stats

public struct AdsStats: Codable, Hashable, Sendable {
    public let zoomMultiplier: Double?
    public let fireRate: Double?
    public let runSpeedMultiplier: Double?
    public let burstCount: Int?
    public let firstBulletAccuracy: Double?
    
    public init(
        zoomMultiplier: Double? = nil,
        fireRate: Double? = nil,
        runSpeedMultiplier: Double? = nil,
        burstCount: Int? = nil,
        firstBulletAccuracy: Double? = nil
    ) {
        self.zoomMultiplier = zoomMultiplier
        self.fireRate = fireRate
        self.runSpeedMultiplier = runSpeedMultiplier
        self.burstCount = burstCount
        self.firstBulletAccuracy = firstBulletAccuracy
    }
}

public struct AltShotgunStats: Codable, Hashable, Sendable {
    public let shotgunPelletCount: Int?
    public let burstRate: Double?
    
    public init(shotgunPelletCount: Int? = nil, burstRate: Double? = nil) {
        self.shotgunPelletCount = shotgunPelletCount
        self.burstRate = burstRate
    }
}

public struct AirBurstStats: Codable, Hashable, Sendable {
    public let shotgunPelletCount: Int?
    public let burstDistance: Double?
    
    public init(shotgunPelletCount: Int? = nil, burstDistance: Double? = nil) {
        self.shotgunPelletCount = shotgunPelletCount
        self.burstDistance = burstDistance
    }
}

// MARK: - Shop Data

public struct ShopData: Codable, Hashable, Sendable {
    public let cost: Int?
    public let category: String?
    public let shopOrderPriority: Int?
    public let categoryText: String?
    public let gridPosition: GridPosition?
    public let canBeTrashed: Bool?
    public let image: String?
    public let newImage: String?
    public let newImage2: String?
    public let assetPath: String?
    
    public init(
        cost: Int? = nil,
        category: String? = nil,
        shopOrderPriority: Int? = nil,
        categoryText: String? = nil,
        gridPosition: GridPosition? = nil,
        canBeTrashed: Bool? = nil,
        image: String? = nil,
        newImage: String? = nil,
        newImage2: String? = nil,
        assetPath: String? = nil
    ) {
        self.cost = cost
        self.category = category
        self.shopOrderPriority = shopOrderPriority
        self.categoryText = categoryText
        self.gridPosition = gridPosition
        self.canBeTrashed = canBeTrashed
        self.image = image
        self.newImage = newImage
        self.newImage2 = newImage2
        self.assetPath = assetPath
    }
}

public struct GridPosition: Codable, Hashable, Sendable {
    public let row: Int?
    public let column: Int?
    
    public init(row: Int? = nil, column: Int? = nil) {
        self.row = row
        self.column = column
    }
}

// MARK: - Weapon Skins & Chromas

public struct WeaponSkin: Codable, Hashable, Identifiable, Sendable {
    public let uuid: String
    public var id: String { uuid }
    public let displayName: String?
    public let themeUuid: String?
    public let contentTierUuid: String?
    public let displayIcon: String?
    public let wallpaper: String?
    public let assetPath: String?
    public let chromas: [Chroma]?
    public let levels: [SkinLevel]?
    
    public init(
        uuid: String,
        displayName: String? = nil,
        themeUuid: String? = nil,
        contentTierUuid: String? = nil,
        displayIcon: String? = nil,
        wallpaper: String? = nil,
        assetPath: String? = nil,
        chromas: [Chroma]? = nil,
        levels: [SkinLevel]? = nil
    ) {
        self.uuid = uuid
        self.displayName = displayName
        self.themeUuid = themeUuid
        self.contentTierUuid = contentTierUuid
        self.displayIcon = displayIcon
        self.wallpaper = wallpaper
        self.assetPath = assetPath
        self.chromas = chromas
        self.levels = levels
    }
    
    // Legacy initializer for backward compatibility
    public init(
        uuid: String,
        displayName: String?,
        displayIcon: String?,
        wallpaper: String?,
        contentTierUuid: String?,
        chromas: [Chroma?]
    ) {
        self.init(
            uuid: uuid,
            displayName: displayName,
            themeUuid: nil,
            contentTierUuid: contentTierUuid,
            displayIcon: displayIcon,
            wallpaper: wallpaper,
            assetPath: nil,
            chromas: chromas.compactMap { $0 },
            levels: nil
        )
    }
}

public struct Chroma: Codable, Hashable, Identifiable, Sendable {
    public let uuid: String
    public var id: String { uuid }
    public let displayName: String?
    public let displayIcon: String?
    public let fullRender: String?
    public let swatch: String?
    public let streamedVideo: String?
    public let assetPath: String?
    
    public init(
        uuid: String,
        displayName: String? = nil,
        displayIcon: String? = nil,
        fullRender: String? = nil,
        swatch: String? = nil,
        streamedVideo: String? = nil,
        assetPath: String? = nil
    ) {
        self.uuid = uuid
        self.displayName = displayName
        self.displayIcon = displayIcon
        self.fullRender = fullRender
        self.swatch = swatch
        self.streamedVideo = streamedVideo
        self.assetPath = assetPath
    }
}

public struct SkinLevel: Codable, Hashable, Identifiable, Sendable {
    public let uuid: String
    public var id: String { uuid }
    public let displayName: String?
    public let levelItem: String?
    public let displayIcon: String?
    public let streamedVideo: String?
    public let assetPath: String?
    
    public init(
        uuid: String,
        displayName: String? = nil,
        levelItem: String? = nil,
        displayIcon: String? = nil,
        streamedVideo: String? = nil,
        assetPath: String? = nil
    ) {
        self.uuid = uuid
        self.displayName = displayName
        self.levelItem = levelItem
        self.displayIcon = displayIcon
        self.streamedVideo = streamedVideo
        self.assetPath = assetPath
    }
}

// MARK: - Legacy Typealiases

public typealias stats = WeaponStats
public typealias damageRanges = DamageRange
public typealias skins = WeaponSkin
public typealias chroma = Chroma

// MARK: - Networking

extension Weapon {
    public static func fetchWeapons(
        forceRefresh: Bool = false,
        service: APIServiceProtocol = APIService.shared
    ) async throws -> [Weapon] {
        let cacheKey = "weapons"
        let cacheDuration: TimeInterval = 60 * 60 * 24 // 24 hours
        let cache = DataCache.shared
        
        // 1. Return fresh cache if available and not forced to refresh
        if !forceRefresh,
           let cacheDate = cache.cacheDate(forKey: cacheKey),
           Date().timeIntervalSince(cacheDate) < cacheDuration,
           let cached: [Weapon] = cache.retrieve(forKey: cacheKey),
           !cached.isEmpty {
            return cached
        }
        
        // 2. Fetch from API service
        do {
            let weapons: [Weapon] = try await service.fetch(endpoint: "weapons")
            cache.cache(weapons, forKey: cacheKey)
            return weapons
        } catch {
            // 3. Fallback to cached data if network fails (even if stale)
            if let cachedFallback: [Weapon] = cache.retrieve(forKey: cacheKey), !cachedFallback.isEmpty {
                return cachedFallback
            }
            throw error
        }
    }
    
    public static func fetchWeapons(
        apiService: APIServiceProtocol,
        forceRefresh: Bool = false
    ) async throws -> [Weapon] {
        try await fetchWeapons(forceRefresh: forceRefresh, service: apiService)
    }
}

// MARK: - Mock Data

public let mockWeapon = Weapon(
    uuid: "63e6c2b6-4a8e-869c-3d4c-e38355226584",
    displayName: "Odin",
    category: "Heavy",
    defaultSkinUuid: "f454efd1-49cb-372f-7096-d394df615308",
    displayIcon: "https://media.valorant-api.com/weapons/63e6c2b6-4a8e-869c-3d4c-e38355226584/displayicon.png",
    killStreamIcon: "https://media.valorant-api.com/weapons/63e6c2b6-4a8e-869c-3d4c-e38355226584/killstreamicon.png",
    weaponStats: WeaponStats(
        fireRate: 12.0,
        magazineSize: 100,
        runSpeedMultiplier: 0.76,
        equipTimeSeconds: 1.25,
        reloadTimeSeconds: 5.0,
        firstBulletAccuracy: 0.8,
        shotgunPelletCount: 1,
        wallPenetration: "EWallPenetrationDisplayType::High",
        damageRanges: [
            DamageRange(
                rangeStartMeters: 0,
                rangeEndMeters: 30,
                headDamage: 95.0,
                bodyDamage: 38.0,
                legDamage: 32.3
            ),
            DamageRange(
                rangeStartMeters: 30,
                rangeEndMeters: 50,
                headDamage: 77.5,
                bodyDamage: 31.0,
                legDamage: 26.35
            )
        ]
    ),
    shopData: ShopData(
        cost: 3200,
        category: "Heavy Weapons",
        shopOrderPriority: 20,
        categoryText: "Heavy Weapons"
    ),
    skins: [
        WeaponSkin(
            uuid: "89be9866-4807-6235-2a95-499cd23828df",
            displayName: "Altitude Odin",
            contentTierUuid: "0cebb8be-46d7-c12a-d306-e9907bfc5a25",
            displayIcon: "https://media.valorant-api.com/weaponskins/89be9866-4807-6235-2a95-499cd23828df/displayicon.png",
            wallpaper: "",
            chromas: [
                Chroma(
                    uuid: "092a25a4-422f-f577-37ac-26a5d489c155",
                    displayName: "Altitude Odin",
                    displayIcon: "",
                    fullRender: "https://media.valorant-api.com/weaponskinchromas/092a25a4-422f-f577-37ac-26a5d489c155/fullrender.png",
                    swatch: ""
                )
            ]
        )
    ]
)

public let mockMeleeWeapon = Weapon(
    uuid: "2f59173c-4bed-b6c3-2191-dea9b58be9c7",
    displayName: "Melee",
    category: "Melee",
    defaultSkinUuid: "f784e1b8-40b4-ebda-6ff6-1a84be891ef9",
    displayIcon: "https://media.valorant-api.com/weapons/2f59173c-4bed-b6c3-2191-dea9b58be9c7/displayicon.png",
    killStreamIcon: "https://media.valorant-api.com/weapons/2f59173c-4bed-b6c3-2191-dea9b58be9c7/killstreamicon.png",
    weaponStats: nil,
    shopData: nil,
    skins: []
)

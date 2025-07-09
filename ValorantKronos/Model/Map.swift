//
//  Map.swift
//  ValorantKronos
//
//  Created by Ethan Montalvo on 17/06/25.
//

import Foundation

class Map: Codable, Identifiable {
    
/// Note: The Map model represents a game map in Valorant, the commented variables are not currently used but may be useful in the future for additional map details.
    var uuid: String
    var displayName: String
//    var narrativeDescription: String?
//    var tacticalDescription: String?
    var coordinates: String?
    var displayIcon: String?
//    var listViewIcon: String?
    var listViewIconTall: String?
    var splash: String?
//    var stylizedBackgroundImage: String?
    var premierBackgroundImage: String?
//    var callouts: [Callout]?

//    struct Callout: Codable, Hashable {
//        let regionName: String
//        let superRegionName: String
//        let location: Location?
//    }
//
//    struct Location: Codable, Hashable {
//        let x: Double
//        let y: Double
//    }
    
    init(uuid: String, displayName: String, coordinates: String? = nil, displayIcon: String? = nil, listViewIconTall: String? = nil, splash: String? = nil, premierBackgroundImage: String? = nil) {
        self.uuid = uuid
        self.displayName = displayName
        self.coordinates = coordinates
        self.displayIcon = displayIcon
        self.listViewIconTall = listViewIconTall
        self.splash = splash
        self.premierBackgroundImage = premierBackgroundImage
    }
}

// MARK: - Networking

extension Map {
    static func fetchMaps(forceRefresh: Bool = false) async throws -> [Map] {
        let cacheKey = "maps"
        let cacheDuration: TimeInterval = 60 * 60 * 24 // 24 hours
        let cache = DataCache.shared
        
        if !forceRefresh,
           let cacheDate = cache.cacheDate(forKey: cacheKey),
           Date().timeIntervalSince(cacheDate) < cacheDuration,
           let cached: [Map] = cache.retrieve(forKey: cacheKey) {
            return cached
        }
        
        let allMaps: [Map] = try await APIService.shared.fetch(endpoint: "maps")
        cache.cache(allMaps, forKey: cacheKey)
        return allMaps
    }
}

// MARK: - Mock Data
let mockMap = Map(
    uuid: "2bee0dc9-4ffe-519b-1cbd-7fbe763a6047",
    displayName: "Haven",
    coordinates: "27°28'A'N,89°38'WZ'E",
    displayIcon: "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/displayicon.png",
    listViewIconTall: "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/listviewicontall.png",
    splash: "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/splash.png",
    premierBackgroundImage: "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/premierbackgroundimage.png"
)

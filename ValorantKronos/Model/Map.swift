//
//  Map.swift
//  ValorantKronos
//
//  Created by Ethan Montalvo on 17/06/25.
//

import Foundation

class Map: Codable, Identifiable {
    
    var uuid: String
    var displayName: String
    
    var coordinates: String
    
    var displayIcon: String?
    var listViewIcon: String?
    var listViewIconTall: String?
    var splash: String?
    var premierBackgroundImage: String?
    
    init (uuid: String, displayName: String, coordinates: String, displayIcon: String? = nil, listViewIcon: String? = nil, listViewIconTall: String? = nil, splash: String? = nil, premierBackgroundImage: String? = nil) {
        self.uuid = uuid
        self.displayName = displayName
        self.coordinates = coordinates
        self.displayIcon = displayIcon
        self.listViewIcon = listViewIcon
        self.listViewIconTall = listViewIconTall
        self.splash = splash
        self.premierBackgroundImage = premierBackgroundImage
    }
}

// MARK: - Mock Data
let mockMap = Map(
    uuid: "2bee0dc9-4ffe-519b-1cbd-7fbe763a6047",
    displayName: "Haven",
    coordinates: "27°28'A'N,89°38'WZ'E",
    displayIcon: "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/displayicon.png",
    listViewIcon: "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/listviewicon.png",
    listViewIconTall: "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/listviewicontall.png",
    splash: "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/splash.png",
    premierBackgroundImage: "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/premierbackgroundimage.png"
)

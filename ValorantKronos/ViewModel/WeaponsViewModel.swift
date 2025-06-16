//
//  WeaponsViewModel.swift
//  ValorantKronos
//
//  Created by Ethan Montalvo on 27/04/25.
//

import Foundation

enum CATEGORY: String, CaseIterable, Identifiable {
    case SIDEARMS
    case RIFLES
    case SMG
    case PISTOLS
    case SNIPERS
    case HEAVY
    
    var id: String { self.rawValue }
}

class WeaponsViewModel: ObservableObject {
    @Published var categories: CATEGORY = .SIDEARMS
    @Published var searchText: String = ""
    @Published var weapons: [Weapon] = Array(repeating: mockWeapon, count: 40)
}

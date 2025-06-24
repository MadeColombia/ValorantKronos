//
//  MapsViewModel.swift
//  ValorantKronos
//
//  Created by Ethan Montalvo on 17/06/25.
//

import Foundation

class MapsViewModel: ObservableObject {
    @Published var maps: [Map] = Array(repeating: mockMap, count: 40)
}

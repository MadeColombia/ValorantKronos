//
//  WeaponsViewModel.swift
//  ValorantKronos
//
//  Created by Ethan Montalvo on 27/04/25.
//  Updated for Milestone 2: Dynamic loading, category normalization & StateManageableViewModel.
//

import Foundation
import Combine

// MARK: - Category Enum

public enum CATEGORY: String, CaseIterable, Identifiable, Sendable {
    case SIDEARMS
    case RIFLES
    case SMG
    case PISTOLS
    case SNIPERS
    case HEAVY
    
    public var id: String { self.rawValue }
    
    /// User-friendly display title (e.g. "Sidearms", "Rifles")
    public var displayName: String {
        switch self {
        case .SIDEARMS: return "Sidearms"
        case .RIFLES: return "Rifles"
        case .SMG: return "SMGs"
        case .PISTOLS: return "Pistols"
        case .SNIPERS: return "Snipers"
        case .HEAVY: return "Heavy"
        }
    }
    
    /// Checks whether a raw category string from API or test fixtures matches this enum case.
    /// Handles "EEquippableCategory::Heavy", "Heavy", singular/plural, and pistols/sidearms interchangeability.
    public func matches(categoryString: String) -> Bool {
        // 1. Strip API prefix if present (e.g. "EEquippableCategory::Heavy" -> "Heavy")
        let clean: String
        if let range = categoryString.range(of: "::") {
            clean = String(categoryString[range.upperBound...])
        } else {
            clean = categoryString
        }
        
        // 2. Exact case-insensitive match (e.g. "Heavy" vs "HEAVY", "SMG" vs "SMG", "Rifles" vs "RIFLES")
        if clean.caseInsensitiveCompare(self.rawValue) == .orderedSame {
            return true
        }
        
        let lowerClean = clean.lowercased()
        let lowerTarget = self.rawValue.lowercased()
        
        // 3. Singular vs. Plural match (e.g. "rifle" <-> "rifles", "sidearm" <-> "sidearms", "sniper" <-> "snipers")
        if lowerClean + "s" == lowerTarget || lowerTarget + "s" == lowerClean {
            return true
        }
        
        // 4. Pistols and Sidearms equivalence in Valorant
        if (self == .SIDEARMS || self == .PISTOLS) &&
           (lowerClean == "sidearm" || lowerClean == "sidearms" || lowerClean == "pistol" || lowerClean == "pistols") {
            return true
        }
        
        return false
    }
    
    /// Convenience match directly against a Weapon instance
    public func matches(weapon: Weapon) -> Bool {
        matches(categoryString: weapon.category)
    }
}

// MARK: - Weapon Category Extension

extension Weapon {
    /// Convenience helper to check if this weapon matches a given CATEGORY
    public func matches(category: CATEGORY) -> Bool {
        category.matches(categoryString: self.category)
    }
}

// MARK: - WeaponsViewModel

@MainActor
public class WeaponsViewModel: ObservableObject, StateManageableViewModel {
    @Published public var categories: CATEGORY = .SIDEARMS
    @Published public var searchText: String = ""
    @Published public var weapons: [Weapon] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var nonBlockingAlertMessage: String? = nil
    
    private let repository: ValorantRepositoryProtocol
    private let service: APIServiceProtocol
    
    /// Returns `true` if the underlying weapons collection is empty.
    public var isEmpty: Bool {
        weapons.isEmpty
    }
    
    public init(
        weapons: [Weapon]? = nil,
        repository: ValorantRepositoryProtocol = ValorantRepository.shared,
        service: APIServiceProtocol = APIService.shared
    ) {
        self.repository = repository
        self.service = service
        
        if let initialWeapons = weapons {
            self.weapons = initialWeapons
        } else {
            let stored = repository.fetchWeaponsFromStorage()
            if !stored.isEmpty {
                self.weapons = stored
            }
        }
    }
    
    // MARK: - Data Loading
    
    /// Loads weapons dynamically from Core Data or API with non-blocking error handling.
    public func loadWeapons(forceRefresh: Bool = false) async {
        if !forceRefresh && !weapons.isEmpty {
            return
        }
        
        if weapons.isEmpty {
            let stored = repository.fetchWeaponsFromStorage()
            if !stored.isEmpty {
                self.weapons = stored
                if !forceRefresh { return }
            }
        }
        
        guard !isLoading else { return }
        if weapons.isEmpty {
            isLoading = true
            errorMessage = nil
        }
        defer { isLoading = false }
        
        do {
            let fetchedWeapons: [Weapon] = try await service.fetch(endpoint: "weapons", parameters: nil)
            try await repository.syncWeapons(fetchedWeapons)
            self.weapons = fetchedWeapons
            self.nonBlockingAlertMessage = nil
            self.errorMessage = nil
        } catch {
            if weapons.isEmpty {
                self.errorMessage = "Failed to load weapons: \(error.userFriendlyMessage)"
            } else {
                self.nonBlockingAlertMessage = "Unable to refresh weapons: \(error.userFriendlyMessage)"
            }
        }
    }
    
    public func clearNonBlockingAlert() {
        nonBlockingAlertMessage = nil
    }
    
    // MARK: - Computed Properties & Filtering
    
    /// Returns weapons matching a specific category, using normalized case-insensitive comparison.
    public func weapons(for category: CATEGORY) -> [Weapon] {
        weapons.filter { category.matches(categoryString: $0.category) }
    }
    
    /// Returns weapons matching a specific category, optionally also filtering by search text.
    public func weapons(for category: CATEGORY, matchingSearch: Bool) -> [Weapon] {
        let categoryMatches = weapons(for: category)
        guard matchingSearch else { return categoryMatches }
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return categoryMatches }
        return categoryMatches.filter { $0.displayName.localizedCaseInsensitiveContains(trimmed) }
    }
    
    /// Weapons filtered by `searchText` across all categories.
    public var searchedWeapons: [Weapon] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return weapons }
        return weapons.filter { $0.displayName.localizedCaseInsensitiveContains(trimmed) }
    }
    
    /// Weapons filtered by currently selected `categories` AND `searchText`.
    public var filteredWeapons: [Weapon] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return weapons.filter { weapon in
            let matchesCategory = categories.matches(categoryString: weapon.category)
            let matchesSearch = trimmed.isEmpty || weapon.displayName.localizedCaseInsensitiveContains(trimmed)
            return matchesCategory && matchesSearch
        }
    }
    
    /// Grouped weapons by CATEGORY enum.
    public var weaponsByCategory: [CATEGORY: [Weapon]] {
        var dict: [CATEGORY: [Weapon]] = [:]
        for cat in CATEGORY.allCases {
            dict[cat] = weapons(for: cat)
        }
        return dict
    }
}


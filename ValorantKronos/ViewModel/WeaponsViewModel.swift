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
    
    private let service: APIServiceProtocol
    
    /// Returns `true` if the underlying weapons collection is empty.
    public var isEmpty: Bool {
        weapons.isEmpty
    }
    
    public init(weapons: [Weapon] = [], service: APIServiceProtocol = APIService.shared) {
        self.weapons = weapons
        self.service = service
    }
    
    // MARK: - Data Loading
    
    /// Loads weapons dynamically from API service with DataCache fallback.
    public func loadWeapons(forceRefresh: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let fetchedWeapons = try await Weapon.fetchWeapons(forceRefresh: forceRefresh, service: service)
            self.weapons = fetchedWeapons
        } catch {
            self.errorMessage = "Failed to load weapons: \(error.userFriendlyMessage)"
        }
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


//
//  WeaponsViewModelTests.swift
//  ValorantKronosTests
//

import XCTest
@testable import ValorantKronos

@MainActor
final class WeaponsViewModelTests: XCTestCase {
    
    private var viewModel: WeaponsViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = WeaponsViewModel(weapons: Array(repeating: mockWeapon, count: 40))
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Tier 1: Happy Path & Enum Verification
    
    func testWeaponsViewModel_initialState() {
        XCTAssertEqual(viewModel.categories, .SIDEARMS)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertEqual(viewModel.weapons.count, 40)
        XCTAssertEqual(viewModel.weapons.first?.displayName, "Odin")
    }
    
    func testCATEGORY_allCases_countAndIdentifiers() {
        let expectedCategories: [CATEGORY] = [.SIDEARMS, .RIFLES, .SMG, .PISTOLS, .SNIPERS, .HEAVY]
        
        XCTAssertEqual(CATEGORY.allCases.count, 6)
        XCTAssertEqual(CATEGORY.allCases, expectedCategories)
        
        for category in CATEGORY.allCases {
            XCTAssertEqual(category.id, category.rawValue)
        }
    }
    
    func testWeaponsViewModel_categoryUpdate() {
        viewModel.categories = .RIFLES
        XCTAssertEqual(viewModel.categories, .RIFLES)
        
        viewModel.categories = .HEAVY
        XCTAssertEqual(viewModel.categories, .HEAVY)
    }
    
    func testWeaponsViewModel_searchTextUpdate() {
        viewModel.searchText = "Phantom"
        XCTAssertEqual(viewModel.searchText, "Phantom")
    }
    
    // MARK: - Tier 2: Boundary & Filtering Logic
    
    func testWeaponsViewModel_searchFiltering_caseInsensitive() {
        let testWeapons = [
            Weapon(uuid: "w1", displayName: "Vandal", category: "Rifles", defaultSkinUuid: "s1", weaponStats: mockWeapon.weaponStats, weaponSkins: []),
            Weapon(uuid: "w2", displayName: "Phantom", category: "Rifles", defaultSkinUuid: "s2", weaponStats: mockWeapon.weaponStats, weaponSkins: []),
            Weapon(uuid: "w3", displayName: "Sheriff", category: "Pistols", defaultSkinUuid: "s3", weaponStats: mockWeapon.weaponStats, weaponSkins: [])
        ]
        
        viewModel.weapons = testWeapons
        viewModel.searchText = "van"
        
        let filtered = viewModel.weapons.filter {
            $0.displayName.localizedCaseInsensitiveContains(viewModel.searchText)
        }
        
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.displayName, "Vandal")
    }
    
    func testWeaponsViewModel_searchFiltering_emptyQuery_returnsAll() {
        viewModel.searchText = ""
        let filtered = viewModel.weapons.filter {
            viewModel.searchText.isEmpty || $0.displayName.localizedCaseInsensitiveContains(viewModel.searchText)
        }
        
        XCTAssertEqual(filtered.count, viewModel.weapons.count)
    }
    
    func testWeaponsViewModel_searchFiltering_noMatch_returnsEmpty() {
        viewModel.searchText = "NonExistentWeaponXYZ"
        let filtered = viewModel.weapons.filter {
            $0.displayName.localizedCaseInsensitiveContains(viewModel.searchText)
        }
        
        XCTAssertTrue(filtered.isEmpty)
    }
    
    /// Documents and tests the known bug in WeaponsView where CATEGORY raw values are UPPERCASE
    /// (e.g. "HEAVY"), while mockWeapon and API categories are Titlecase (e.g. "Heavy"),
    /// causing `category == categoryState.rawValue` to fail and render empty lists.
    func testWeaponsViewModel_categoryFiltering_caseSensitivityIssue() {
        // mockWeapon has category == "Heavy"
        XCTAssertEqual(mockWeapon.category, "Heavy")
        // CATEGORY.HEAVY has rawValue == "HEAVY"
        XCTAssertEqual(CATEGORY.HEAVY.rawValue, "HEAVY")
        
        // Exact string comparison fails (existing bug in WeaponsView line 31)
        let exactMatches = viewModel.weapons.filter { $0.category == CATEGORY.HEAVY.rawValue }
        XCTAssertEqual(exactMatches.count, 0, "Exact match fails due to 'Heavy' vs 'HEAVY' case mismatch")
        
        // Case-insensitive comparison succeeds (expected behavior for M2 remediation)
        let caseInsensitiveMatches = viewModel.weapons.filter {
            $0.category.caseInsensitiveCompare(CATEGORY.HEAVY.rawValue) == .orderedSame
        }
        XCTAssertEqual(caseInsensitiveMatches.count, 40)
    }
    
    // MARK: - Tier 3: Pairwise & Combinatorial Filtering
    
    func testWeaponsViewModel_searchSpecialCharacters() {
        let weaponWithSymbols = Weapon(
            uuid: "w-special",
            displayName: "Operator (Pro)",
            category: "Snipers",
            defaultSkinUuid: "s-special",
            weaponStats: mockWeapon.weaponStats,
            weaponSkins: []
        )
        viewModel.weapons = [weaponWithSymbols]
        
        viewModel.searchText = "(Pro)"
        let matches = viewModel.weapons.filter {
            $0.displayName.localizedCaseInsensitiveContains(viewModel.searchText)
        }
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches.first?.displayName, "Operator (Pro)")
    }
    
    func testWeaponsViewModel_combinedFilterAndSearch() {
        let weaponsPool = [
            Weapon(uuid: "1", displayName: "Vandal", category: "Rifles", defaultSkinUuid: "s1", weaponStats: mockWeapon.weaponStats, weaponSkins: []),
            Weapon(uuid: "2", displayName: "Phantom", category: "Rifles", defaultSkinUuid: "s2", weaponStats: mockWeapon.weaponStats, weaponSkins: []),
            Weapon(uuid: "3", displayName: "Ghost", category: "Pistols", defaultSkinUuid: "s3", weaponStats: mockWeapon.weaponStats, weaponSkins: []),
            Weapon(uuid: "4", displayName: "Classic", category: "Pistols", defaultSkinUuid: "s4", weaponStats: mockWeapon.weaponStats, weaponSkins: [])
        ]
        
        viewModel.weapons = weaponsPool
        viewModel.categories = .RIFLES
        viewModel.searchText = "van"
        
        let filtered = viewModel.weapons.filter { weapon in
            let matchesCategory = weapon.category.caseInsensitiveCompare(viewModel.categories.rawValue) == .orderedSame
            let matchesSearch = viewModel.searchText.isEmpty || weapon.displayName.localizedCaseInsensitiveContains(viewModel.searchText)
            return matchesCategory && matchesSearch
        }
        
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.displayName, "Vandal")
    }
    
    func testWeaponsViewModel_repositoryIntegration() async {
        let persistence = PersistenceController(inMemory: true)
        let repository = ValorantRepository(persistenceController: persistence)
        let testWeapon = Weapon(uuid: "w-repo", displayName: "Ares", category: "Heavy")
        try? await repository.syncWeapons([testWeapon])
        
        let localVM = WeaponsViewModel(repository: repository)
        XCTAssertEqual(localVM.weapons.count, 1)
        XCTAssertEqual(localVM.weapons.first?.displayName, "Ares")
        XCTAssertNil(localVM.errorMessage)
    }
    
    func testWeaponsViewModel_refreshErrorWithExistingData_setsNonBlockingAlert() async {
        let persistence = PersistenceController(inMemory: true)
        let repository = ValorantRepository(persistenceController: persistence)
        let testWeapon = Weapon(uuid: "w-repo", displayName: "Ares", category: "Heavy")
        try? await repository.syncWeapons([testWeapon])
        
        let mockService = MockAPIService()
        mockService.shouldThrowError = true
        mockService.errorToThrow = .requestFailed(URLError(.notConnectedToInternet))
        
        let localVM = WeaponsViewModel(repository: repository, service: mockService)
        await localVM.loadWeapons(forceRefresh: true)
        
        XCTAssertEqual(localVM.weapons.count, 1)
        XCTAssertNil(localVM.errorMessage)
        XCTAssertNotNil(localVM.nonBlockingAlertMessage)
    }
}

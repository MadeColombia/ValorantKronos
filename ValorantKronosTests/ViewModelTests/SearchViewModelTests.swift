//
//  SearchViewModelTests.swift
//  ValorantKronosTests
//
//  Created by Teamwork Agent on 12/09/26.
//  Comprehensive test suite for SearchViewModel.
//

import XCTest
@testable import ValorantKronos

@MainActor
final class SearchViewModelTests: XCTestCase {
    
    private var persistence: PersistenceController!
    private var repository: ValorantRepository!
    private var viewModel: SearchViewModel!
    
    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()
        URLProtocol.registerClass(MockURLProtocol.self)
        DataCache.shared.clearCache()
        persistence = PersistenceController(inMemory: true)
        repository = ValorantRepository(persistenceController: persistence)
        viewModel = SearchViewModel(agents: [], weapons: [], maps: [], repository: repository)
    }
    
    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        MockURLProtocol.reset()
        DataCache.shared.clearCache()
        viewModel = nil
        repository = nil
        persistence = nil
        super.tearDown()
    }
    
    // MARK: - Test Fixture Helpers
    
    private func createSampleAgents() -> [Agent] {
        let duelist = Role(id: "r1", displayName: "Duelist", description: "Duelist role")
        let initiator = Role(id: "r2", displayName: "Initiator", description: "Initiator role")
        
        let jett = Agent(
            uuid: "jett-1",
            displayName: "Jett",
            developerName: "Wushu",
            description: "Wind agent",
            fullPortrait: nil,
            background: nil,
            isPlayableCharacter: true,
            role: duelist,
            abilities: []
        )
        
        let sova = Agent(
            uuid: "sova-1",
            displayName: "Sova",
            developerName: "Hunter",
            description: "Recon agent",
            fullPortrait: nil,
            background: nil,
            isPlayableCharacter: true,
            role: initiator,
            abilities: []
        )
        
        return [jett, sova]
    }
    
    private func createSampleWeapons() -> [Weapon] {
        let vandal = Weapon(
            uuid: "w-vandal",
            displayName: "Vandal",
            category: "Rifles",
            defaultSkinUuid: "s-vandal",
            weaponStats: mockWeapon.weaponStats,
            weaponSkins: []
        )
        let sheriff = Weapon(
            uuid: "w-sheriff",
            displayName: "Sheriff",
            category: "Pistols",
            defaultSkinUuid: "s-sheriff",
            weaponStats: mockWeapon.weaponStats,
            weaponSkins: []
        )
        return [vandal, sheriff]
    }
    
    private func createSampleMaps() -> [Map] {
        let haven = Map(
            uuid: "m-haven",
            displayName: "Haven",
            coordinates: "27°28'N",
            displayIcon: "https://icon/haven.png"
        )
        let bind = Map(
            uuid: "m-bind",
            displayName: "Bind",
            coordinates: "34°02'N",
            displayIcon: "https://icon/bind.png"
        )
        let theRange = Map(
            uuid: "m-range",
            displayName: "The Range",
            coordinates: nil,
            displayIcon: nil
        )
        return [haven, bind, theRange]
    }
    
    // MARK: - Tier 1: Initial State & Scopes
    
    func testSearchViewModel_initialState() {
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertEqual(viewModel.selectedScope, .all)
        XCTAssertTrue(viewModel.matchingAgents.isEmpty)
        XCTAssertTrue(viewModel.matchingWeapons.isEmpty)
        XCTAssertTrue(viewModel.matchingMaps.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.isEmpty)
        XCTAssertFalse(viewModel.hasResults)
        XCTAssertEqual(viewModel.totalResultCount, 0)
        XCTAssertTrue(viewModel.isQueryEmpty)
        XCTAssertFalse(viewModel.noResultsFound)
        XCTAssertFalse(viewModel.isDataLoaded)
    }
    
    func testSearchScope_allCasesAndInitialization() {
        XCTAssertEqual(SearchScope.allCases.count, 4)
        XCTAssertEqual(SearchScope(rawValue: "all"), .all)
        XCTAssertEqual(SearchScope(rawValue: "ALL"), .all)
        XCTAssertEqual(SearchScope(rawValue: "agents"), .agents)
        XCTAssertEqual(SearchScope(rawValue: "Weapons"), .weapons)
        XCTAssertEqual(SearchScope(rawValue: "maps"), .maps)
        XCTAssertNil(SearchScope(rawValue: "unknown_scope"))
        
        XCTAssertEqual(SearchScope.all.displayName, "All")
        XCTAssertEqual(SearchScope.agents.displayName, "Agents")
        XCTAssertEqual(SearchScope.weapons.displayName, "Weapons")
        XCTAssertEqual(SearchScope.maps.displayName, "Maps")
    }
    
    // MARK: - Tier 2: Filtering with Seeding Initializer
    
    func testSearchViewModel_seedingInitializer_populatesAllWhenQueryEmpty() {
        let vm = SearchViewModel(
            agents: createSampleAgents(),
            weapons: createSampleWeapons(),
            maps: createSampleMaps()
        )
        
        XCTAssertFalse(vm.isEmpty)
        XCTAssertTrue(vm.hasResults)
        XCTAssertTrue(vm.isDataLoaded)
        XCTAssertEqual(vm.matchingAgents.count, 2)
        XCTAssertEqual(vm.matchingWeapons.count, 2)
        XCTAssertEqual(vm.matchingMaps.count, 2, "The Range (nil icon) should be excluded")
        XCTAssertEqual(vm.totalResultCount, 6)
    }
    
    func testSearchViewModel_searchByAgentName() {
        let vm = SearchViewModel(
            agents: createSampleAgents(),
            weapons: createSampleWeapons(),
            maps: createSampleMaps()
        )
        
        vm.searchText = "jett"
        
        XCTAssertEqual(vm.matchingAgents.count, 1)
        XCTAssertEqual(vm.matchingAgents.first?.displayName, "Jett")
        XCTAssertEqual(vm.matchingWeapons.count, 0)
        XCTAssertEqual(vm.matchingMaps.count, 0)
        XCTAssertTrue(vm.hasResults)
        XCTAssertFalse(vm.isEmpty)
    }
    
    func testSearchViewModel_searchByAgentRole() {
        let vm = SearchViewModel(
            agents: createSampleAgents(),
            weapons: createSampleWeapons(),
            maps: createSampleMaps()
        )
        
        vm.searchText = "Initiator"
        
        XCTAssertEqual(vm.matchingAgents.count, 1)
        XCTAssertEqual(vm.matchingAgents.first?.displayName, "Sova")
    }
    
    func testSearchViewModel_searchByWeaponNameAndCategory() {
        let vm = SearchViewModel(
            agents: createSampleAgents(),
            weapons: createSampleWeapons(),
            maps: createSampleMaps()
        )
        
        // Search by weapon name
        vm.searchText = "vandal"
        XCTAssertEqual(vm.matchingWeapons.count, 1)
        XCTAssertEqual(vm.matchingWeapons.first?.displayName, "Vandal")
        
        // Search by category
        vm.searchText = "pistols"
        XCTAssertEqual(vm.matchingWeapons.count, 1)
        XCTAssertEqual(vm.matchingWeapons.first?.displayName, "Sheriff")
    }
    
    func testSearchViewModel_searchByMapName() {
        let vm = SearchViewModel(
            agents: createSampleAgents(),
            weapons: createSampleWeapons(),
            maps: createSampleMaps()
        )
        
        vm.searchText = "haven"
        XCTAssertEqual(vm.matchingMaps.count, 1)
        XCTAssertEqual(vm.matchingMaps.first?.displayName, "Haven")
        XCTAssertEqual(vm.matchingAgents.count, 0)
        XCTAssertEqual(vm.matchingWeapons.count, 0)
    }
    
    func testSearchViewModel_noResultsFoundState() {
        let vm = SearchViewModel(
            agents: createSampleAgents(),
            weapons: createSampleWeapons(),
            maps: createSampleMaps()
        )
        
        vm.searchText = "NonExistentEntity12345"
        
        XCTAssertTrue(vm.isEmpty)
        XCTAssertFalse(vm.hasResults)
        XCTAssertTrue(vm.noResultsFound)
        XCTAssertFalse(vm.isQueryEmpty)
    }
    
    // MARK: - Tier 3: Scope Switching
    
    func testSearchViewModel_scopeFiltering_agentsOnly() {
        let vm = SearchViewModel(
            agents: createSampleAgents(),
            weapons: createSampleWeapons(),
            maps: createSampleMaps()
        )
        
        vm.selectedScope = .agents
        
        XCTAssertEqual(vm.matchingAgents.count, 2)
        XCTAssertEqual(vm.matchingWeapons.count, 0)
        XCTAssertEqual(vm.matchingMaps.count, 0)
    }
    
    func testSearchViewModel_scopeFiltering_weaponsOnly() {
        let vm = SearchViewModel(
            agents: createSampleAgents(),
            weapons: createSampleWeapons(),
            maps: createSampleMaps()
        )
        
        vm.selectedScope = .weapons
        
        XCTAssertEqual(vm.matchingAgents.count, 0)
        XCTAssertEqual(vm.matchingWeapons.count, 2)
        XCTAssertEqual(vm.matchingMaps.count, 0)
    }
    
    func testSearchViewModel_scopeFiltering_mapsOnly() {
        let vm = SearchViewModel(
            agents: createSampleAgents(),
            weapons: createSampleWeapons(),
            maps: createSampleMaps()
        )
        
        vm.selectedScope = .maps
        
        XCTAssertEqual(vm.matchingAgents.count, 0)
        XCTAssertEqual(vm.matchingWeapons.count, 0)
        XCTAssertEqual(vm.matchingMaps.count, 2)
    }
    
    func testSearchViewModel_scopeSwitchingWithActiveQuery() {
        let vm = SearchViewModel(
            agents: createSampleAgents(),
            weapons: createSampleWeapons(),
            maps: createSampleMaps()
        )
        
        // "van" matches Vandal
        vm.searchText = "van"
        XCTAssertEqual(vm.matchingWeapons.count, 1)
        
        // Switch scope to .agents -> Vandal should be hidden
        vm.selectedScope = .agents
        XCTAssertEqual(vm.matchingWeapons.count, 0)
        XCTAssertEqual(vm.matchingAgents.count, 0)
        
        // Switch back to .weapons -> Vandal reappears
        vm.selectedScope = .weapons
        XCTAssertEqual(vm.matchingWeapons.count, 1)
        
        // Switch to .all -> Vandal remains visible
        vm.selectedScope = .all
        XCTAssertEqual(vm.matchingWeapons.count, 1)
    }
    
    // MARK: - Tier 4: Async Network Loading & Error Handling
    
    func testSearchViewModel_loadAllData_success() async {
        let agentJSON = JSONFixtures.validAgentSovaJSON
        let agentsResponse = JSONFixtures.wrapInAPIResponse(innerJSON: "[\(agentJSON)]", status: 200)
        let weaponJSON = JSONFixtures.validStandardWeaponJSON
        let weaponsResponse = JSONFixtures.wrapInAPIResponse(innerJSON: "[\(weaponJSON)]", status: 200)
        let mapJSON = JSONFixtures.validMapHavenJSON
        let mapsResponse = JSONFixtures.wrapInAPIResponse(innerJSON: "[\(mapJSON)]", status: 200)
        
        MockURLProtocol.requestHandler = { request in
            let url = request.url?.absoluteString ?? ""
            let data: Data
            if url.contains("agents") {
                data = agentsResponse.data(using: .utf8)!
            } else if url.contains("weapons") {
                data = weaponsResponse.data(using: .utf8)!
            } else if url.contains("maps") {
                data = mapsResponse.data(using: .utf8)!
            } else {
                data = Data()
            }
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        XCTAssertFalse(viewModel.isLoading)
        await viewModel.loadAllData()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.allAgents.count, 1)
        XCTAssertEqual(viewModel.allWeapons.count, 1)
        XCTAssertEqual(viewModel.allMaps.count, 1)
        XCTAssertTrue(viewModel.hasResults)
    }
    
    func testSearchViewModel_loadAllData_networkFailure() async {
        MockURLProtocol.mockError = URLError(.notConnectedToInternet)
        
        await viewModel.loadAllData(forceRefresh: true)
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("Failed to load search data") ?? false)
    }
    
    func testSearchViewModel_loadAllData_readsFromCacheWhenAvailable() async {
        let cachedAgent = mockAgent
        let cachedWeapon = mockWeapon
        let cachedMap = mockMap
        
        DataCache.shared.save([cachedAgent], forKey: "agents")
        DataCache.shared.save([cachedWeapon], forKey: "weapons")
        DataCache.shared.save([cachedMap], forKey: "maps")
        
        // Load without network mocking
        await viewModel.loadAllData(forceRefresh: false)
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.allAgents.count, 1)
        XCTAssertEqual(viewModel.allWeapons.count, 1)
        XCTAssertEqual(viewModel.allMaps.count, 1)
        XCTAssertEqual(viewModel.matchingAgents.first?.displayName, mockAgent.displayName)
    }
}

//
//  MapsViewModelTests.swift
//  ValorantKronosTests
//

import XCTest
@testable import ValorantKronos

@MainActor
final class MapsViewModelTests: XCTestCase {
    
    private var persistence: PersistenceController!
    private var repository: ValorantRepository!
    private var viewModel: MapsViewModel!
    
    override func setUp() {
        super.setUp()
        persistence = PersistenceController(inMemory: true)
        repository = ValorantRepository(persistenceController: persistence)
        viewModel = MapsViewModel(maps: [], repository: repository)
        MockURLProtocol.reset()
        URLProtocol.registerClass(MockURLProtocol.self)
        DataCache.shared.clearCache()
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
    
    // MARK: - Helper Methods
    
    private func createTestMaps() -> [Map] {
        let haven = Map(
            uuid: "map-1",
            displayName: "Haven",
            coordinates: "27°28'A'N,89°38'WZ'E",
            displayIcon: "https://media.valorant-api.com/haven/icon.png",
            listViewIconTall: "https://media.valorant-api.com/haven/tall.png",
            splash: "https://media.valorant-api.com/haven/splash.png"
        )
        
        let bind = Map(
            uuid: "map-2",
            displayName: "Bind",
            coordinates: "34°2'A'N,6°51'Z'W",
            displayIcon: "https://media.valorant-api.com/bind/icon.png",
            listViewIconTall: "https://media.valorant-api.com/bind/tall.png",
            splash: "https://media.valorant-api.com/bind/splash.png"
        )
        
        let rangeWithoutIcon = Map(
            uuid: "map-3",
            displayName: "The Range",
            coordinates: nil,
            displayIcon: nil,
            listViewIconTall: "https://media.valorant-api.com/range/tall.png",
            splash: "https://media.valorant-api.com/range/splash.png"
        )
        
        return [haven, bind, rangeWithoutIcon]
    }
    
    // MARK: - Tier 1: Happy Path & Filtering
    
    func testMapsViewModel_initialState() {
        XCTAssertTrue(viewModel.maps.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testMapsViewModel_filterMaps_retainsOnlyMapsWithDisplayIcon() {
        let testMaps = createTestMaps()
        viewModel.maps = testMaps
        
        XCTAssertEqual(viewModel.maps.count, 3)
        viewModel.filterMaps()
        
        XCTAssertEqual(viewModel.maps.count, 2)
        XCTAssertTrue(viewModel.maps.allSatisfy { $0.displayIcon != nil })
        XCTAssertFalse(viewModel.maps.contains { $0.displayName == "The Range" })
    }
    
    // MARK: - Tier 2: Boundary & Corner Cases
    
    func testMapsViewModel_filterMaps_allMapsLackDisplayIcon_resultsInEmpty() {
        let map1 = Map(uuid: "m1", displayName: "Range 1", displayIcon: nil)
        let map2 = Map(uuid: "m2", displayName: "Range 2", displayIcon: nil)
        viewModel.maps = [map1, map2]
        
        viewModel.filterMaps()
        XCTAssertTrue(viewModel.maps.isEmpty)
    }
    
    func testMapsViewModel_filterMaps_allMapsHaveDisplayIcon_retainsAll() {
        let haven = Map(uuid: "m1", displayName: "Haven", displayIcon: "https://icon.png")
        let bind = Map(uuid: "m2", displayName: "Bind", displayIcon: "https://icon.png")
        viewModel.maps = [haven, bind]
        
        viewModel.filterMaps()
        XCTAssertEqual(viewModel.maps.count, 2)
    }
    
    func testMapsViewModel_filterMaps_emptyList_remainsEmpty() {
        viewModel.maps = []
        viewModel.filterMaps()
        XCTAssertTrue(viewModel.maps.isEmpty)
    }
    
    func testMapsViewModel_loadMaps_loadingStateTransitions_success() async {
        let mapJSON = JSONFixtures.validMapHavenJSON
        let responseJSON = JSONFixtures.wrapInAPIResponse(innerJSON: "[\(mapJSON)]", status: 200)
        MockURLProtocol.mockStatusCode = 200
        MockURLProtocol.mockResponseData = responseJSON.data(using: .utf8)!
        
        XCTAssertFalse(viewModel.isLoading)
        
        await viewModel.loadMaps()
        
        XCTAssertFalse(viewModel.isLoading, "isLoading must be false after completion")
        XCTAssertNil(viewModel.errorMessage, "errorMessage must be nil on success")
        XCTAssertEqual(viewModel.maps.count, 1)
        XCTAssertEqual(viewModel.maps.first?.displayName, "Haven")
    }
    
    func testMapsViewModel_loadMaps_errorStateHandling() async {
        MockURLProtocol.mockError = URLError(.notConnectedToInternet)
        
        await viewModel.loadMaps(forceRefresh: true)
        
        XCTAssertFalse(viewModel.isLoading, "isLoading must be false after error")
        XCTAssertNotNil(viewModel.errorMessage, "errorMessage must be set on failure")
        XCTAssertTrue(viewModel.errorMessage?.contains("Failed to load maps") ?? false)
        XCTAssertTrue(viewModel.maps.isEmpty)
    }
    
    // MARK: - Tier 3: Search & Cache Integration
    
    func testMapsViewModel_searchFiltering_byDisplayName() {
        viewModel.maps = createTestMaps()
        
        let query = "hav"
        let filtered = viewModel.maps.filter {
            $0.displayName.localizedCaseInsensitiveContains(query)
        }
        
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.displayName, "Haven")
    }
    
    func testMapsViewModel_repositoryIntegration() async {
        let cachedMap = mockMap
        try? await repository.syncMaps([cachedMap])
        
        let localVM = MapsViewModel(repository: repository)
        XCTAssertEqual(localVM.maps.count, 1)
        XCTAssertEqual(localVM.maps.first?.displayName, mockMap.displayName)
        XCTAssertNil(localVM.errorMessage)
    }
    
    func testMapsViewModel_refreshErrorWithExistingData_setsNonBlockingAlert() async {
        let cachedMap = mockMap
        try? await repository.syncMaps([cachedMap])
        let localVM = MapsViewModel(repository: repository)
        
        MockURLProtocol.mockError = URLError(.notConnectedToInternet)
        await localVM.loadMaps(forceRefresh: true)
        
        XCTAssertEqual(localVM.maps.count, 1)
        XCTAssertNil(localVM.errorMessage)
        XCTAssertNotNil(localVM.nonBlockingAlertMessage)
    }
}

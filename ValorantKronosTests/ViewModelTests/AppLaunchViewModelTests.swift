//
//  AppLaunchViewModelTests.swift
//  ValorantKronosTests
//
//  Created by Pair Programming Assistant on 15/09/26.
//

import XCTest
@testable import ValorantKronos

@MainActor
final class AppLaunchViewModelTests: XCTestCase {
    private var persistence: PersistenceController!
    private var repository: ValorantRepository!
    private var mockService: MockAPIService!
    
    override func setUp() {
        super.setUp()
        persistence = PersistenceController(inMemory: true)
        repository = ValorantRepository(persistenceController: persistence)
        mockService = MockAPIService()
    }
    
    override func tearDown() {
        persistence = nil
        repository = nil
        mockService = nil
        super.tearDown()
    }
    
    func testFastLaunchWhenDataAlreadyExists() async {
        let agent = Agent(uuid: "a1", displayName: "A", developerName: nil, description: "", fullPortrait: nil, background: nil, isPlayableCharacter: true, role: nil, abilities: [])
        let weapon = Weapon(uuid: "w1", displayName: "W", category: "Rifle")
        let map = Map(uuid: "m1", displayName: "M")
        
        try? await repository.syncAgents([agent])
        try? await repository.syncWeapons([weapon])
        try? await repository.syncMaps([map])
        
        let viewModel = AppLaunchViewModel(repository: repository, apiService: mockService)
        XCTAssertFalse(viewModel.isReady)
        
        await viewModel.startInitialization()
        
        XCTAssertTrue(viewModel.isReady)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testColdLaunchBulkPreloadSuccess() async {
        let testAgent = Agent(uuid: "a1", displayName: "Jett", developerName: nil, description: "", fullPortrait: nil, background: nil, isPlayableCharacter: true, role: nil, abilities: [])
        let testWeapon = Weapon(uuid: "w1", displayName: "Vandal", category: "Rifle")
        let testMap = Map(uuid: "m1", displayName: "Haven")
        
        mockService.stubbedAgents = [testAgent]
        mockService.stubbedWeapons = [testWeapon]
        mockService.stubbedMaps = [testMap]
        
        let viewModel = AppLaunchViewModel(repository: repository, apiService: mockService)
        XCTAssertFalse(viewModel.isReady)
        
        await viewModel.startInitialization()
        
        XCTAssertTrue(viewModel.isReady)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(repository.hasInitialData())
        XCTAssertEqual(repository.fetchAgentsFromStorage().count, 1)
        XCTAssertEqual(repository.fetchWeaponsFromStorage().count, 1)
        XCTAssertEqual(repository.fetchMapsFromStorage().count, 1)
    }
    
    func testColdLaunchFailureShowsError() async {
        mockService.shouldThrowError = true
        mockService.errorToThrow = .invalidURL
        
        let viewModel = AppLaunchViewModel(repository: repository, apiService: mockService)
        await viewModel.startInitialization()
        
        XCTAssertFalse(viewModel.isReady)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}

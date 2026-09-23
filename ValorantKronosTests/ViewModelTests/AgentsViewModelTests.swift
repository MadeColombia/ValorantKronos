//
//  AgentsViewModelTests.swift
//  ValorantKronosTests
//

import XCTest
@testable import ValorantKronos

@MainActor
final class AgentsViewModelTests: XCTestCase {
    
    private var persistence: PersistenceController!
    private var repository: ValorantRepository!
    private var viewModel: AgentsViewModel!
    
    override func setUp() {
        super.setUp()
        persistence = PersistenceController(inMemory: true)
        repository = ValorantRepository(persistenceController: persistence)
        viewModel = AgentsViewModel(agents: [], repository: repository)
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
    
    private func createTestAgents() -> [Agent] {
        let duelistRole = Role(id: "r1", displayName: "Duelist", description: "Duelist role")
        let initiatorRole = Role(id: "r2", displayName: "Initiator", description: "Initiator role")
        let sentinelRole = Role(id: "r3", displayName: "Sentinel", description: "Sentinel role")
        
        let jett = Agent(
            uuid: "jett-uuid",
            displayName: "Jett",
            developerName: "Wushu",
            description: "Agile fighter",
            fullPortrait: nil,
            background: nil,
            isPlayableCharacter: true,
            role: duelistRole,
            abilities: []
        )
        
        let phoenix = Agent(
            uuid: "phoenix-uuid",
            displayName: "Phoenix",
            developerName: "Flame",
            description: "Fiery fighter",
            fullPortrait: nil,
            background: nil,
            isPlayableCharacter: true,
            role: duelistRole,
            abilities: []
        )
        
        let sova = Agent(
            uuid: "sova-uuid",
            displayName: "Sova",
            developerName: "Hunter",
            description: "Recon expert",
            fullPortrait: nil,
            background: nil,
            isPlayableCharacter: true,
            role: initiatorRole,
            abilities: []
        )
        
        let sage = Agent(
            uuid: "sage-uuid",
            displayName: "Sage",
            developerName: "Thorne",
            description: "Healer and wall",
            fullPortrait: nil,
            background: nil,
            isPlayableCharacter: true,
            role: sentinelRole,
            abilities: []
        )
        
        let unknownAgent = Agent(
            uuid: "unknown-uuid",
            displayName: "KAY/O Beta",
            developerName: "Bot",
            description: "No role assigned",
            fullPortrait: nil,
            background: nil,
            isPlayableCharacter: false,
            role: nil,
            abilities: []
        )
        
        return [jett, phoenix, sova, sage, unknownAgent]
    }
    
    // MARK: - Tier 1: Happy Path & Filtering
    
    func testAgentsViewModel_initialState() {
        XCTAssertTrue(viewModel.agents.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.selectedRoleFilter, "ALL AGENTS")
        XCTAssertEqual(viewModel.agentFilterOptions, ["ALL AGENTS": "ALL AGENTS"])
        XCTAssertTrue(viewModel.filteredAgents.isEmpty)
    }
    
    func testAgentsViewModel_filteredAgents_whenAllAgentsSelected() {
        let testAgents = createTestAgents()
        viewModel.agents = testAgents
        viewModel.selectedRoleFilter = "ALL AGENTS"
        
        XCTAssertEqual(viewModel.filteredAgents.count, testAgents.count)
        XCTAssertEqual(viewModel.filteredAgents.map { $0.displayName }, testAgents.map { $0.displayName })
    }
    
    func testAgentsViewModel_filteredAgents_whenRoleSelected() {
        viewModel.agents = createTestAgents()
        
        // Filter by Duelist
        viewModel.selectedRoleFilter = "Duelist"
        XCTAssertEqual(viewModel.filteredAgents.count, 2)
        XCTAssertTrue(viewModel.filteredAgents.allSatisfy { $0.role?.displayName == "Duelist" })
        
        // Filter by Initiator
        viewModel.selectedRoleFilter = "Initiator"
        XCTAssertEqual(viewModel.filteredAgents.count, 1)
        XCTAssertEqual(viewModel.filteredAgents.first?.displayName, "Sova")
        
        // Filter by Sentinel
        viewModel.selectedRoleFilter = "Sentinel"
        XCTAssertEqual(viewModel.filteredAgents.count, 1)
        XCTAssertEqual(viewModel.filteredAgents.first?.displayName, "Sage")
    }
    
    func testAgentsViewModel_agentsByRole_grouping() {
        viewModel.agents = createTestAgents()
        let grouped = viewModel.agentsByRole()
        
        XCTAssertEqual(grouped["Duelist"]?.count, 2)
        XCTAssertEqual(grouped["Initiator"]?.count, 1)
        XCTAssertEqual(grouped["Sentinel"]?.count, 1)
        XCTAssertEqual(grouped["Unknown"]?.count, 1)
    }
    
    // MARK: - Tier 2: Boundary & Corner Cases
    
    func testAgentsViewModel_agentsByRole_agentWithNilRole_groupsUnderUnknown() {
        let agentWithoutRole = Agent(
            uuid: "norole-1",
            displayName: "Test Dummy",
            developerName: "Dummy",
            description: "Practice dummy",
            fullPortrait: nil,
            background: nil,
            isPlayableCharacter: false,
            role: nil,
            abilities: []
        )
        viewModel.agents = [agentWithoutRole]
        
        let grouped = viewModel.agentsByRole()
        XCTAssertEqual(grouped["Unknown"]?.count, 1)
        XCTAssertEqual(grouped["Unknown"]?.first?.displayName, "Test Dummy")
    }
    
    func testAgentsViewModel_filteredAgents_nonExistentRole_returnsEmpty() {
        viewModel.agents = createTestAgents()
        viewModel.selectedRoleFilter = "NonExistentRole"
        
        XCTAssertTrue(viewModel.filteredAgents.isEmpty)
    }
    
    func testAgentsViewModel_filteredAgents_emptyAgentsList_returnsEmpty() {
        viewModel.agents = []
        viewModel.selectedRoleFilter = "Duelist"
        
        XCTAssertTrue(viewModel.filteredAgents.isEmpty)
    }
    
    func testAgentsViewModel_loadAgents_loadingStateTransitions_success() async {
        let agentJSON = JSONFixtures.validAgentSovaJSON
        let responseJSON = JSONFixtures.wrapInAPIResponse(innerJSON: "[\(agentJSON)]", status: 200)
        MockURLProtocol.mockStatusCode = 200
        MockURLProtocol.mockResponseData = responseJSON.data(using: .utf8)!
        
        XCTAssertFalse(viewModel.isLoading)
        
        await viewModel.loadAgents()
        
        XCTAssertFalse(viewModel.isLoading, "isLoading must be false after completion")
        XCTAssertNil(viewModel.errorMessage, "errorMessage must be nil on success")
        XCTAssertEqual(viewModel.agents.count, 1)
        XCTAssertEqual(viewModel.agents.first?.displayName, "Sova")
        XCTAssertNotNil(viewModel.agentFilterOptions["Initiator"])
        XCTAssertEqual(viewModel.agentFilterOptions["Initiator"], "INITIATORS")
    }
    
    func testAgentsViewModel_loadAgents_errorStateHandling() async {
        MockURLProtocol.mockError = URLError(.notConnectedToInternet)
        
        await viewModel.loadAgents(forceRefresh: true)
        
        XCTAssertFalse(viewModel.isLoading, "isLoading must be false after error")
        XCTAssertNotNil(viewModel.errorMessage, "errorMessage must be populated on failure")
        XCTAssertTrue(viewModel.errorMessage?.contains("Failed to load agents") ?? false)
        XCTAssertTrue(viewModel.agents.isEmpty)
    }
    
    // MARK: - Tier 3: Pairwise & State Transitions
    
    func testAgentsViewModel_sequentialRoleFilterSwitching() {
        viewModel.agents = createTestAgents()
        
        // 1. Initial ALL AGENTS
        XCTAssertEqual(viewModel.filteredAgents.count, 5)
        
        // 2. Switch to Duelist
        viewModel.selectedRoleFilter = "Duelist"
        XCTAssertEqual(viewModel.filteredAgents.count, 2)
        
        // 3. Switch to Initiator
        viewModel.selectedRoleFilter = "Initiator"
        XCTAssertEqual(viewModel.filteredAgents.count, 1)
        
        // 4. Switch to Unknown
        viewModel.selectedRoleFilter = "Unknown"
        XCTAssertEqual(viewModel.filteredAgents.count, 1)
        
        // 5. Switch back to ALL AGENTS
        viewModel.selectedRoleFilter = "ALL AGENTS"
        XCTAssertEqual(viewModel.filteredAgents.count, 5)
    }
    
    func testAgentsViewModel_repositoryIntegration() async {
        let cachedAgent = mockAgent
        try? await repository.syncAgents([cachedAgent])
        
        let localVM = AgentsViewModel(repository: repository)
        XCTAssertEqual(localVM.agents.count, 1)
        XCTAssertEqual(localVM.agents.first?.displayName, mockAgent.displayName)
        XCTAssertNil(localVM.errorMessage)
    }
    
    func testAgentsViewModel_refreshErrorWithExistingData_setsNonBlockingAlert() async {
        let cachedAgent = mockAgent
        try? await repository.syncAgents([cachedAgent])
        let localVM = AgentsViewModel(repository: repository)
        
        MockURLProtocol.mockError = URLError(.notConnectedToInternet)
        await localVM.loadAgents(forceRefresh: true)
        
        XCTAssertEqual(localVM.agents.count, 1)
        XCTAssertNil(localVM.errorMessage, "Should not display full-screen blocking error when cache exists")
        XCTAssertNotNil(localVM.nonBlockingAlertMessage, "Should set nonBlockingAlertMessage")
    }
}

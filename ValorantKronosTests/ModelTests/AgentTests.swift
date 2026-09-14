//
//  AgentTests.swift
//  ValorantKronosTests
//

import XCTest
@testable import ValorantKronos

final class AgentTests: XCTestCase {
    
    private var jsonDecoder: JSONDecoder!
    private var jsonEncoder: JSONEncoder!
    
    override func setUp() {
        super.setUp()
        jsonDecoder = JSONDecoder()
        jsonEncoder = JSONEncoder()
    }
    
    override func tearDown() {
        jsonDecoder = nil
        jsonEncoder = nil
        super.tearDown()
    }
    
    // MARK: - Tier 1: Happy Path & Core Logic
    
    func testAgentDecoding_validJSON_populatesAllFields() throws {
        let data = JSONFixtures.validAgentSovaJSON.data(using: .utf8)!
        let agent = try jsonDecoder.decode(Agent.self, from: data)
        
        XCTAssertEqual(agent.uuid, "320b2a48-4d9b-a075-30f1-1f93a9b638fa")
        XCTAssertEqual(agent.displayName, "Sova")
        XCTAssertEqual(agent.developerName, "Hunter")
        XCTAssertTrue(agent.description.contains("eternal winter of Russia's tundra"))
        XCTAssertEqual(agent.fullPortrait, "https://media.valorant-api.com/agents/320b2a48-4d9b-a075-30f1-1f93a9b638fa/fullportrait.png")
        XCTAssertEqual(agent.background, "https://media.valorant-api.com/agents/320b2a48-4d9b-a075-30f1-1f93a9b638fa/background.png")
        XCTAssertEqual(agent.isPlayableCharacter, true)
        XCTAssertNotNil(agent.role)
        XCTAssertEqual(agent.abilities.count, 5)
    }
    
    func testRoleDecoding_validJSON_populatesRole() throws {
        let data = JSONFixtures.validAgentSovaJSON.data(using: .utf8)!
        let agent = try jsonDecoder.decode(Agent.self, from: data)
        let role = try XCTUnwrap(agent.role)
        
        XCTAssertEqual(role.id, "1b47567f-8f7b-444b-aae3-b0c634622d10")
        XCTAssertEqual(role.displayName, "Initiator")
        XCTAssertTrue(role.description?.contains("Initiators challenge angles") ?? false)
        XCTAssertEqual(role.displayIcon, "https://media.valorant-api.com/agents/roles/1b47567f-8f7b-444b-aae3-b0c634622d10/displayicon.png")
    }
    
    func testAbilitiesDecoding_validJSON_populatesAllAbilities() throws {
        let data = JSONFixtures.validAgentSovaJSON.data(using: .utf8)!
        let agent = try jsonDecoder.decode(Agent.self, from: data)
        
        XCTAssertEqual(agent.abilities.count, 5)
        
        let slots = agent.abilities.map { $0.slot }
        XCTAssertTrue(slots.contains("Ability1"))
        XCTAssertTrue(slots.contains("Ability2"))
        XCTAssertTrue(slots.contains("Grenade"))
        XCTAssertTrue(slots.contains("Ultimate"))
        XCTAssertTrue(slots.contains("Passive"))
        
        let ability1 = agent.abilities.first { $0.slot == "Ability1" }
        XCTAssertNotNil(ability1)
        XCTAssertEqual(ability1?.displayName, "Shock Bolt")
        XCTAssertEqual(ability1?.displayIcon, "https://media.valorant-api.com/agents/320b2a48-4d9b-a075-30f1-1f93a9b638fa/abilities/ability1/displayicon.png")
        
        let passive = agent.abilities.first { $0.slot == "Passive" }
        XCTAssertNotNil(passive)
        XCTAssertEqual(passive?.displayName, "Uncanny Marksman")
        XCTAssertNil(passive?.displayIcon)
    }
    
    func testAgentCodableRoundtrip() throws {
        let original = mockAgent
        let encodedData = try jsonEncoder.encode(original)
        let decodedAgent = try jsonDecoder.decode(Agent.self, from: encodedData)
        
        XCTAssertEqual(decodedAgent.uuid, original.uuid)
        XCTAssertEqual(decodedAgent.displayName, original.displayName)
        XCTAssertEqual(decodedAgent.developerName, original.developerName)
        XCTAssertEqual(decodedAgent.description, original.description)
        XCTAssertEqual(decodedAgent.isPlayableCharacter, original.isPlayableCharacter)
        XCTAssertEqual(decodedAgent.role?.displayName, original.role?.displayName)
        XCTAssertEqual(decodedAgent.abilities.count, original.abilities.count)
    }
    
    func testAgentInit_defaultValues() {
        let agent = Agent(
            uuid: "test-uuid-123",
            displayName: "Brimstone",
            developerName: nil,
            description: "Commander",
            fullPortrait: nil,
            background: nil,
            isPlayableCharacter: nil,
            role: nil,
            abilities: []
        )
        
        XCTAssertEqual(agent.uuid, "test-uuid-123")
        XCTAssertEqual(agent.displayName, "Brimstone")
        XCTAssertEqual(agent.developerName, "Unknown", "Nil developerName should default to 'Unknown'")
        XCTAssertEqual(agent.isPlayableCharacter, false, "Nil isPlayableCharacter should default to false")
        XCTAssertNil(agent.role)
        XCTAssertTrue(agent.abilities.isEmpty)
    }
    
    func testRoleCapitalization() {
        let role = Role(id: "uuid-1", displayName: "duelist", description: "First fragger", displayIcon: nil)
        XCTAssertEqual(role.displayName, "Duelist", "Role displayName should be capitalized by initializer")
    }
    
    func testMockAgentIntegrity() {
        XCTAssertEqual(mockAgent.displayName, "SOVA")
        XCTAssertEqual(mockAgent.developerName, "MIRATZVE")
        XCTAssertEqual(mockAgent.role?.displayName, "Initiator")
        XCTAssertEqual(mockAgent.abilities.count, 5)
    }
    
    // MARK: - Tier 2: Boundary & Corner Cases
    
    func testAgentDecoding_nullRole_success() throws {
        let data = JSONFixtures.agentWithNullRoleJSON.data(using: .utf8)!
        let agent = try jsonDecoder.decode(Agent.self, from: data)
        
        XCTAssertEqual(agent.uuid, "ded3520f-4264-bfed-162d-b080e2abccf9")
        XCTAssertEqual(agent.displayName, "Training Bot")
        XCTAssertNil(agent.role)
        XCTAssertTrue(agent.abilities.isEmpty)
        XCTAssertEqual(agent.isPlayableCharacter, false)
    }
    
    func testAgentDecoding_emptyAbilities_success() throws {
        let data = JSONFixtures.agentWithNullRoleJSON.data(using: .utf8)!
        let agent = try jsonDecoder.decode(Agent.self, from: data)
        
        XCTAssertTrue(agent.abilities.isEmpty)
    }
    
    func testAgentDecoding_specialCharactersInName() throws {
        let data = JSONFixtures.agentWithSpecialCharactersJSON.data(using: .utf8)!
        let agent = try jsonDecoder.decode(Agent.self, from: data)
        
        XCTAssertEqual(agent.displayName, "KAY/O")
        XCTAssertEqual(agent.developerName, "Grenadier")
        XCTAssertEqual(agent.abilities.first?.displayName, "FLASH/drive")
    }
    
    func testAgentDecoding_missingRequiredUUID_throwsError() {
        let data = JSONFixtures.malformedAgentMissingUUIDJSON.data(using: .utf8)!
        XCTAssertThrowsError(try jsonDecoder.decode(Agent.self, from: data)) { error in
            guard case DecodingError.keyNotFound(let key, _) = error else {
                XCTFail("Expected keyNotFound error, got: \(error)")
                return
            }
            XCTAssertEqual(key.stringValue, "uuid")
        }
    }
    
    func testAgentDecoding_typeMismatch_throwsError() {
        let data = JSONFixtures.malformedAgentTypeMismatchJSON.data(using: .utf8)!
        XCTAssertThrowsError(try jsonDecoder.decode(Agent.self, from: data)) { error in
            guard case DecodingError.typeMismatch = error else {
                XCTFail("Expected typeMismatch error, got: \(error)")
                return
            }
        }
    }
    
    func testAgentDecoding_corruptedBytes_throwsError() {
        let corruptedData = Data([0x00, 0xFF, 0xFE, 0x12, 0x44])
        XCTAssertThrowsError(try jsonDecoder.decode(Agent.self, from: corruptedData))
    }
    
    func testAgentDecoding_fromAPIResponseEnvelope() throws {
        let wrappedJSON = JSONFixtures.wrapInAPIResponse(innerJSON: "[\(JSONFixtures.validAgentSovaJSON)]")
        let data = wrappedJSON.data(using: .utf8)!
        let response = try jsonDecoder.decode(APIResponse<[Agent]>.self, from: data)
        
        XCTAssertEqual(response.status, 200)
        XCTAssertEqual(response.data.count, 1)
        XCTAssertEqual(response.data.first?.displayName, "Sova")
    }
}

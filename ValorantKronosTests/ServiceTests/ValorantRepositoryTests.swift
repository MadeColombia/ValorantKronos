//
//  ValorantRepositoryTests.swift
//  ValorantKronosTests
//
//  Created by Pair Programming Assistant on 15/09/26.
//

import XCTest
import CoreData
@testable import ValorantKronos

final class ValorantRepositoryTests: XCTestCase {
    private var repository: ValorantRepository!
    private var persistence: PersistenceController!
    
    override func setUp() {
        super.setUp()
        persistence = PersistenceController(inMemory: true)
        repository = ValorantRepository(persistenceController: persistence)
    }
    
    override func tearDown() {
        repository = nil
        persistence = nil
        super.tearDown()
    }
    
    func testInitialDataEmpty() {
        XCTAssertFalse(repository.hasInitialData())
        XCTAssertEqual(repository.fetchAgentsFromStorage().count, 0)
        XCTAssertEqual(repository.fetchWeaponsFromStorage().count, 0)
        XCTAssertEqual(repository.fetchMapsFromStorage().count, 0)
    }
    
    func testSyncAndFetchAgents() async throws {
        let agent1 = Agent(
            uuid: "test-agent-1",
            displayName: "Jett",
            developerName: "Wushu",
            description: "Agile duelist from South Korea",
            fullPortrait: "https://example.com/jett.png",
            background: nil,
            isPlayableCharacter: true,
            role: Role(id: "duelist-id", displayName: "Duelist", description: "First blood", displayIcon: nil),
            abilities: [
                Ability(slot: "Ability1", displayName: "Updraft", description: "Jump high", displayIcon: nil)
            ]
        )
        
        let changed = try await repository.syncAgents([agent1])
        XCTAssertTrue(changed)
        
        let saved = repository.fetchAgentsFromStorage()
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.uuid, "test-agent-1")
        XCTAssertEqual(saved.first?.displayName, "Jett")
        XCTAssertEqual(saved.first?.role?.displayName, "Duelist")
        XCTAssertEqual(saved.first?.abilities.count, 1)
        XCTAssertEqual(saved.first?.abilities.first?.displayName, "Updraft")
    }
    
    func testSmartUpsertAgents() async throws {
        let agentInitial = Agent(
            uuid: "test-agent-1",
            displayName: "Jett",
            developerName: "Wushu",
            description: "Agile duelist",
            fullPortrait: nil,
            background: nil,
            isPlayableCharacter: true,
            role: nil,
            abilities: []
        )
        _ = try await repository.syncAgents([agentInitial])
        
        // Update display name
        let agentUpdated = Agent(
            uuid: "test-agent-1",
            displayName: "Jett (Wind)",
            developerName: "Wushu",
            description: "Updated description",
            fullPortrait: nil,
            background: nil,
            isPlayableCharacter: true,
            role: nil,
            abilities: []
        )
        let changed = try await repository.syncAgents([agentUpdated])
        XCTAssertTrue(changed)
        
        let saved = repository.fetchAgentsFromStorage()
        XCTAssertEqual(saved.count, 1, "Upsert must not duplicate entities with same UUID")
        XCTAssertEqual(saved.first?.displayName, "Jett (Wind)")
        XCTAssertEqual(saved.first?.description, "Updated description")
        
        // Second sync with identical data should report no changes
        let noChange = try await repository.syncAgents([agentUpdated])
        XCTAssertFalse(noChange)
    }
    
    func testPruningObsoleteAgents() async throws {
        let agent1 = Agent(uuid: "agent-1", displayName: "Jett", developerName: nil, description: "", fullPortrait: nil, background: nil, isPlayableCharacter: true, role: nil, abilities: [])
        let agent2 = Agent(uuid: "agent-2", displayName: "Phoenix", developerName: nil, description: "", fullPortrait: nil, background: nil, isPlayableCharacter: true, role: nil, abilities: [])
        
        _ = try await repository.syncAgents([agent1, agent2])
        XCTAssertEqual(repository.fetchAgentsFromStorage().count, 2)
        
        // Next sync only includes agent2; agent1 should be pruned
        let changed = try await repository.syncAgents([agent2])
        XCTAssertTrue(changed)
        
        let saved = repository.fetchAgentsFromStorage()
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.uuid, "agent-2")
    }
    
    func testSyncAndFetchWeapons() async throws {
        let weapon = Weapon(
            uuid: "weapon-vandal-1",
            displayName: "Vandal",
            category: "EEquippableCategory::Rifle",
            displayIcon: "https://example.com/vandal.png",
            weaponStats: WeaponStats(
                fireRate: 9.75,
                magazineSize: 25,
                runSpeedMultiplier: 0.73,
                equipTimeSeconds: 1.0,
                reloadTimeSeconds: 2.5,
                firstBulletAccuracy: 0.25,
                shotgunPelletCount: 1,
                wallPenetration: "Medium",
                feature: nil,
                fireMode: nil,
                altFireType: nil,
                adsStats: nil,
                altShotgunStats: nil,
                airBurstStats: nil,
                damageRanges: [
                    DamageRange(rangeStartMeters: 0, rangeEndMeters: 50, headDamage: 160.0, bodyDamage: 40.0, legDamage: 34.0)
                ]
            )
        )
        
        let changed = try await repository.syncWeapons([weapon])
        XCTAssertTrue(changed)
        
        let saved = repository.fetchWeaponsFromStorage()
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.displayName, "Vandal")
        XCTAssertEqual(saved.first?.weaponStats?.fireRate, 9.75)
        XCTAssertEqual(saved.first?.weaponStats?.damageRanges.first?.headDamage, 160.0)
    }
    
    func testSyncAndFetchMaps() async throws {
        let map = Map(
            uuid: "map-haven-1",
            displayName: "Haven",
            coordinates: "27°28'N, 89°38'E",
            displayIcon: "https://example.com/haven-icon.png",
            listViewIconTall: nil,
            splash: "https://example.com/haven-splash.png"
        )
        
        let changed = try await repository.syncMaps([map])
        XCTAssertTrue(changed)
        
        let saved = repository.fetchMapsFromStorage()
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.displayName, "Haven")
        XCTAssertEqual(saved.first?.coordinates, "27°28'N, 89°38'E")
    }
    
    func testHasInitialDataWhenAllPopulated() async throws {
        let agent = Agent(uuid: "a1", displayName: "A", developerName: nil, description: "", fullPortrait: nil, background: nil, isPlayableCharacter: true, role: nil, abilities: [])
        let weapon = Weapon(uuid: "w1", displayName: "W", category: "Rifle")
        let map = Map(uuid: "m1", displayName: "M")
        
        _ = try await repository.syncAgents([agent])
        XCTAssertFalse(repository.hasInitialData())
        
        _ = try await repository.syncWeapons([weapon])
        XCTAssertFalse(repository.hasInitialData())
        
        _ = try await repository.syncMaps([map])
        XCTAssertTrue(repository.hasInitialData())
        
        try await repository.clearAllData()
        XCTAssertFalse(repository.hasInitialData())
    }
}

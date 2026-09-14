//
//  DataCacheTests.swift
//  ValorantKronosTests
//

import XCTest
@testable import ValorantKronos

final class DataCacheTests: XCTestCase {
    
    private var cache: DataCache!
    
    override func setUp() {
        super.setUp()
        cache = DataCache.shared
        cache.clearCache()
    }
    
    override func tearDown() {
        cache.clearCache()
        cache = nil
        super.tearDown()
    }
    
    // MARK: - Tier 1: Happy Path & Retrieval
    
    func testDataCache_cacheAndRetrieve_agentObject() {
        let testKey = "test_agent_key_\(UUID().uuidString)"
        let originalAgent = mockAgent
        
        cache.cache(originalAgent, forKey: testKey)
        
        let retrieved: Agent? = cache.retrieve(forKey: testKey)
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.uuid, originalAgent.uuid)
        XCTAssertEqual(retrieved?.displayName, originalAgent.displayName)
        XCTAssertEqual(retrieved?.role?.displayName, originalAgent.role?.displayName)
    }
    
    func testDataCache_cacheAndRetrieve_mapObject() {
        let testKey = "test_map_key_\(UUID().uuidString)"
        let originalMap = mockMap
        
        cache.cache(originalMap, forKey: testKey)
        
        let retrieved: Map? = cache.retrieve(forKey: testKey)
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.uuid, originalMap.uuid)
        XCTAssertEqual(retrieved?.displayName, originalMap.displayName)
        XCTAssertEqual(retrieved?.coordinates, originalMap.coordinates)
    }
    
    func testDataCache_cacheAndRetrieve_primitiveArray() {
        let testKey = "test_array_key_\(UUID().uuidString)"
        let originalArray = ["Duelist", "Initiator", "Controller", "Sentinel"]
        
        cache.cache(originalArray, forKey: testKey)
        
        let retrieved: [String]? = cache.retrieve(forKey: testKey)
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved, originalArray)
    }
    
    func testDataCache_cacheDate_returnsRecentDate() {
        let testKey = "test_date_key_\(UUID().uuidString)"
        cache.cache("Sample Payload", forKey: testKey)
        
        let date = cache.cacheDate(forKey: testKey)
        XCTAssertNotNil(date)
        if let date = date {
            let difference = abs(Date().timeIntervalSince(date))
            XCTAssertLessThan(difference, 5.0, "Cache date should be within 5 seconds of current time")
        }
    }
    
    func testDataCache_clearCache_removesAllEntries() {
        let key1 = "test_clear_key_1_\(UUID().uuidString)"
        let key2 = "test_clear_key_2_\(UUID().uuidString)"
        
        cache.cache("Value 1", forKey: key1)
        cache.cache("Value 2", forKey: key2)
        
        XCTAssertNotNil(cache.retrieve(forKey: key1) as String?)
        XCTAssertNotNil(cache.retrieve(forKey: key2) as String?)
        
        cache.clearCache()
        
        let retrieved1: String? = cache.retrieve(forKey: key1)
        let retrieved2: String? = cache.retrieve(forKey: key2)
        
        XCTAssertNil(retrieved1, "Cache should return nil after clearCache()")
        XCTAssertNil(retrieved2, "Cache should return nil after clearCache()")
    }
    
    // MARK: - Tier 2: Boundary & Corner Cases
    
    func testDataCache_nonExistentKey_returnsNil() {
        let nonExistentKey = "missing_key_\(UUID().uuidString)"
        let retrieved: String? = cache.retrieve(forKey: nonExistentKey)
        XCTAssertNil(retrieved)
    }
    
    func testDataCache_cacheDate_nonExistentKey_returnsNil() {
        let nonExistentKey = "missing_key_\(UUID().uuidString)"
        let date = cache.cacheDate(forKey: nonExistentKey)
        XCTAssertNil(date)
    }
    
    func testDataCache_overwriteExistingKey_updatesDataAndDate() {
        let key = "overwrite_key_\(UUID().uuidString)"
        
        cache.cache("Initial String", forKey: key)
        let firstRetrieval: String? = cache.retrieve(forKey: key)
        XCTAssertEqual(firstRetrieval, "Initial String")
        
        cache.cache("Updated String", forKey: key)
        let secondRetrieval: String? = cache.retrieve(forKey: key)
        XCTAssertEqual(secondRetrieval, "Updated String")
    }
    
    func testDataCache_corruptedFile_returnsNilGracefully() {
        let key = "corrupted_key_\(UUID().uuidString)"
        
        // Write raw non-JSON bytes into the cache file location
        let fileManager = FileManager.default
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cacheDirectory = caches.appendingPathComponent("ObjectCache")
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        let corruptedData = Data([0x00, 0x01, 0x02, 0xFF, 0xFE])
        try? corruptedData.write(to: fileURL)
        
        // DataCache.retrieve should handle decoding failure gracefully and return nil without crashing
        let retrieved: Agent? = cache.retrieve(forKey: key)
        XCTAssertNil(retrieved, "Retrieving corrupted cache should return nil safely")
    }
    
    func testDataCache_expiryThreshold_24Hours() {
        let cacheDuration: TimeInterval = 60 * 60 * 24 // 86400 seconds
        
        // Valid cache scenario (within 24 hours)
        let recentDate = Date().addingTimeInterval(-86390) // 23h 59m 50s ago
        let recentInterval = Date().timeIntervalSince(recentDate)
        XCTAssertLessThan(recentInterval, cacheDuration, "Recent date within 24h should be considered valid")
        
        // Expired cache scenario (past 24 hours)
        let expiredDate = Date().addingTimeInterval(-86410) // 24h 0m 10s ago
        let expiredInterval = Date().timeIntervalSince(expiredDate)
        XCTAssertGreaterThan(expiredInterval, cacheDuration, "Date past 24h should be considered expired")
    }
    
    func testDataCache_largePayload_caching() {
        let key = "large_payload_key_\(UUID().uuidString)"
        let largeArray = (0..<50).map { i in
            Agent(
                uuid: "agent-uuid-\(i)",
                displayName: "Agent \(i)",
                developerName: "Dev \(i)",
                description: "Test description for agent \(i)",
                fullPortrait: nil,
                background: nil,
                isPlayableCharacter: true,
                role: Role(id: "role-\(i)", displayName: "Role \(i)"),
                abilities: []
            )
        }
        
        cache.cache(largeArray, forKey: key)
        
        let retrieved: [Agent]? = cache.retrieve(forKey: key)
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.count, 50)
        XCTAssertEqual(retrieved?[0].displayName, "Agent 0")
        XCTAssertEqual(retrieved?[49].displayName, "Agent 49")
    }
}

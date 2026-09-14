//
//  WeaponTests.swift
//  ValorantKronosTests
//

import XCTest
@testable import ValorantKronos

final class WeaponTests: XCTestCase {
    
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
    
    func testWeaponDecoding_validJSON_populatesAllFields() throws {
        let data = JSONFixtures.validStandardWeaponJSON.data(using: .utf8)!
        let weapon = try jsonDecoder.decode(Weapon.self, from: data)
        
        XCTAssertEqual(weapon.uuid, "63e6c2b6-4a8e-869c-3d4c-e38355226584")
        XCTAssertEqual(weapon.displayName, "Odin")
        XCTAssertEqual(weapon.category, "Heavy")
        XCTAssertEqual(weapon.defaultSkinUuid, "f454efd1-49cb-372f-7096-d394df615308")
        XCTAssertEqual(weapon.displayIcon, "https://media.valorant-api.com/weapons/63e6c2b6-4a8e-869c-3d4c-e38355226584/displayicon.png")
        XCTAssertEqual(weapon.killStreamIcon, "https://media.valorant-api.com/weapons/63e6c2b6-4a8e-869c-3d4c-e38355226584/killstreamicon.png")
        XCTAssertNotNil(weapon.weaponStats)
        XCTAssertEqual(weapon.weaponSkins.count, 1)
    }
    
    func testWeaponStatsDecoding_validJSON_populatesStats() throws {
        let data = JSONFixtures.validStandardWeaponJSON.data(using: .utf8)!
        let weapon = try jsonDecoder.decode(Weapon.self, from: data)
        let weaponStats = try XCTUnwrap(weapon.weaponStats)
        
        XCTAssertEqual(weaponStats.fireRate, 12.0, accuracy: 0.001)
        XCTAssertEqual(weaponStats.magazineSize, 100)
        XCTAssertEqual(weaponStats.runSpeedMultiplier, 0.76, accuracy: 0.001)
        XCTAssertEqual(weaponStats.equipTimeSeconds, 1.25, accuracy: 0.001)
        XCTAssertEqual(weaponStats.reloadTimeSeconds, 5.0, accuracy: 0.001)
        XCTAssertEqual(weaponStats.firstBulletAccuracy, 0.8, accuracy: 0.001)
        XCTAssertEqual(weaponStats.shotgunPelletCount, 1)
    }
    
    func testDamageRangesDecoding_validJSON_populatesRanges() throws {
        let data = JSONFixtures.validStandardWeaponJSON.data(using: .utf8)!
        let weapon = try jsonDecoder.decode(Weapon.self, from: data)
        let weaponStats = try XCTUnwrap(weapon.weaponStats)
        
        XCTAssertEqual(weaponStats.damageRanges.count, 1)
        let range = weaponStats.damageRanges[0]
        XCTAssertEqual(range.rangeStartMeters, 0)
        XCTAssertEqual(range.rangeEndMeters, 30)
        XCTAssertEqual(range.headDamage, 95.0, accuracy: 0.001)
        XCTAssertEqual(range.bodyDamage, 38.0, accuracy: 0.001)
        XCTAssertEqual(range.legDamage, 32.3, accuracy: 0.001)
    }
    
    func testWeaponSkinsAndChromasDecoding_populatesNestedCollections() throws {
        let data = JSONFixtures.validStandardWeaponJSON.data(using: .utf8)!
        let weapon = try jsonDecoder.decode(Weapon.self, from: data)
        
        XCTAssertEqual(weapon.weaponSkins.count, 1)
        let skin = weapon.weaponSkins[0]
        XCTAssertEqual(skin.uuid, "89be9866-4807-6235-2a95-499cd23828df")
        XCTAssertEqual(skin.displayName, "Altitude Odin")
        XCTAssertEqual(skin.wallpaper, "https://media.valorant-api.com/wallpaper.png")
        XCTAssertEqual(skin.contentTierUuid, "0cebb8be-46d7-c12a-d306-e9907bfc5a25")
        
        let chromas = skin.chromas ?? []
        XCTAssertEqual(chromas.count, 1)
        let chroma = chromas[0]
        XCTAssertEqual(chroma.uuid, "092a25a4-422f-f577-37ac-26a5d489c155")
        XCTAssertEqual(chroma.displayName, "Altitude Odin Chroma 1")
        XCTAssertEqual(chroma.displayIcon, "https://media.valorant-api.com/chroma1.png")
        XCTAssertEqual(chroma.fullRender, "https://media.valorant-api.com/weaponskinchromas/092a25a4-422f-f577-37ac-26a5d489c155/fullrender.png")
        XCTAssertEqual(chroma.swatch, "https://media.valorant-api.com/swatch.png")
    }
    
    func testWeaponCodableRoundtrip() throws {
        let original = mockWeapon
        let encodedData = try jsonEncoder.encode(original)
        let decodedWeapon = try jsonDecoder.decode(Weapon.self, from: encodedData)
        
        XCTAssertEqual(decodedWeapon.uuid, original.uuid)
        XCTAssertEqual(decodedWeapon.displayName, original.displayName)
        XCTAssertEqual(decodedWeapon.category, original.category)
        XCTAssertEqual(decodedWeapon.defaultSkinUuid, original.defaultSkinUuid)
        XCTAssertEqual(decodedWeapon.displayIcon, original.displayIcon)
        XCTAssertEqual(decodedWeapon.weaponStats?.fireRate, original.weaponStats?.fireRate)
        XCTAssertEqual(decodedWeapon.weaponStats?.magazineSize, original.weaponStats?.magazineSize)
        XCTAssertEqual(decodedWeapon.weaponSkins.count, original.weaponSkins.count)
    }
    
    func testWeaponIdMatchesUuid() {
        XCTAssertEqual(mockWeapon.id, mockWeapon.uuid)
    }
    
    func testMockWeaponIntegrity() {
        XCTAssertEqual(mockWeapon.displayName, "Odin")
        XCTAssertEqual(mockWeapon.category, "Heavy")
        XCTAssertEqual(mockWeapon.weaponStats?.magazineSize, 100)
        XCTAssertEqual(mockWeapon.weaponStats?.fireRate, 12.0)
        XCTAssertFalse(mockWeapon.weaponSkins.isEmpty)
    }
    
    // MARK: - Tier 2: Boundary & Corner Cases
    
    /// Tests decoding of melee weapon with null stats (e.g. Knife / Tactical Melee).
    /// Under the repaired Weapon schema, weaponStats is optional (WeaponStats?),
    /// allowing melee weapons to decode successfully without errors.
    func testWeaponDecoding_meleeWeaponNullStats_success() throws {
        let data = JSONFixtures.meleeWeaponNullStatsJSON.data(using: .utf8)!
        let weapon = try jsonDecoder.decode(Weapon.self, from: data)
        
        XCTAssertEqual(weapon.uuid, "2f59173c-4bed-b6c3-2191-dea9b58be9c7")
        XCTAssertEqual(weapon.displayName, "Melee")
        XCTAssertEqual(weapon.category, "Melee")
        XCTAssertNil(weapon.weaponStats, "Melee weapon weaponStats must decode to nil")
        XCTAssertFalse(weapon.weaponSkins.isEmpty)
    }
    
    func testMockMeleeWeaponIntegrity() {
        XCTAssertEqual(mockMeleeWeapon.displayName, "Melee")
        XCTAssertEqual(mockMeleeWeapon.category, "Melee")
        XCTAssertNil(mockMeleeWeapon.weaponStats)
    }
    
    func testWeaponDecoding_nilDisplayIcons_success() throws {
        let data = JSONFixtures.weaponWithNilIconsJSON.data(using: .utf8)!
        let weapon = try jsonDecoder.decode(Weapon.self, from: data)
        
        XCTAssertEqual(weapon.uuid, "ee824247-4563-30ec-4a5e-f4464c544d67")
        XCTAssertEqual(weapon.displayName, "Ghost")
        XCTAssertNil(weapon.displayIcon)
        XCTAssertNil(weapon.killStreamIcon)
        XCTAssertTrue(weapon.weaponSkins.isEmpty)
        XCTAssertEqual(weapon.weaponStats?.fireRate, 6.75)
    }
    
    func testWeaponDecoding_emptySkinsArray_success() throws {
        let data = JSONFixtures.weaponWithNilIconsJSON.data(using: .utf8)!
        let weapon = try jsonDecoder.decode(Weapon.self, from: data)
        
        XCTAssertEqual(weapon.weaponSkins.count, 0)
    }
    
    func testWeaponStats_damageRangesPrecision() throws {
        let data = JSONFixtures.validStandardWeaponJSON.data(using: .utf8)!
        let weapon = try jsonDecoder.decode(Weapon.self, from: data)
        let stats = try XCTUnwrap(weapon.weaponStats)
        let range = try XCTUnwrap(stats.damageRanges.first)
        
        XCTAssertEqual(range.headDamage, 95.0, accuracy: 0.0001)
        XCTAssertEqual(range.bodyDamage, 38.0, accuracy: 0.0001)
        XCTAssertEqual(range.legDamage, 32.3, accuracy: 0.0001)
    }
    
    func testWeaponDecoding_missingRequiredUUID_throwsError() {
        let data = JSONFixtures.malformedWeaponMissingUUIDJSON.data(using: .utf8)!
        XCTAssertThrowsError(try jsonDecoder.decode(Weapon.self, from: data)) { error in
            guard case DecodingError.keyNotFound(let key, _) = error else {
                XCTFail("Expected keyNotFound error, got: \(error)")
                return
            }
            XCTAssertEqual(key.stringValue, "uuid")
        }
    }
    
    func testWeaponDecoding_corruptedBytes_throwsError() {
        let corruptedData = Data([0xDE, 0xAD, 0xBE, 0xEF])
        XCTAssertThrowsError(try jsonDecoder.decode(Weapon.self, from: corruptedData))
    }
    
    func testWeaponDecoding_fromAPIResponseEnvelope() throws {
        let wrappedJSON = JSONFixtures.wrapInAPIResponse(innerJSON: "[\(JSONFixtures.validStandardWeaponJSON)]")
        let data = wrappedJSON.data(using: .utf8)!
        let response = try jsonDecoder.decode(APIResponse<[Weapon]>.self, from: data)
        
        XCTAssertEqual(response.status, 200)
        XCTAssertEqual(response.data.count, 1)
        XCTAssertEqual(response.data.first?.displayName, "Odin")
    }
}

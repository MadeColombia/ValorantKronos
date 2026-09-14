//
//  MapTests.swift
//  ValorantKronosTests
//

import XCTest
@testable import ValorantKronos

final class MapTests: XCTestCase {
    
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
    
    func testMapDecoding_validJSON_populatesAllFields() throws {
        let data = JSONFixtures.validMapHavenJSON.data(using: .utf8)!
        let map = try jsonDecoder.decode(Map.self, from: data)
        
        XCTAssertEqual(map.uuid, "2bee0dc9-4ffe-519b-1cbd-7fbe763a6047")
        XCTAssertEqual(map.displayName, "Haven")
        XCTAssertEqual(map.coordinates, "27°28'A'N,89°38'WZ'E")
        XCTAssertEqual(map.displayIcon, "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/displayicon.png")
        XCTAssertEqual(map.listViewIconTall, "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/listviewicontall.png")
        XCTAssertEqual(map.splash, "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/splash.png")
        XCTAssertEqual(map.premierBackgroundImage, "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/premierbackgroundimage.png")
    }
    
    func testMapCodableRoundtrip() throws {
        let original = mockMap
        let encodedData = try jsonEncoder.encode(original)
        let decodedMap = try jsonDecoder.decode(Map.self, from: encodedData)
        
        XCTAssertEqual(decodedMap.uuid, original.uuid)
        XCTAssertEqual(decodedMap.displayName, original.displayName)
        XCTAssertEqual(decodedMap.coordinates, original.coordinates)
        XCTAssertEqual(decodedMap.displayIcon, original.displayIcon)
        XCTAssertEqual(decodedMap.listViewIconTall, original.listViewIconTall)
        XCTAssertEqual(decodedMap.splash, original.splash)
        XCTAssertEqual(decodedMap.premierBackgroundImage, original.premierBackgroundImage)
    }
    
    func testMapInit_withNilOptionalFields() {
        let map = Map(
            uuid: "custom-map-uuid",
            displayName: "Ascent",
            coordinates: nil,
            displayIcon: nil,
            listViewIconTall: nil,
            splash: nil,
            premierBackgroundImage: nil
        )
        
        XCTAssertEqual(map.uuid, "custom-map-uuid")
        XCTAssertEqual(map.displayName, "Ascent")
        XCTAssertNil(map.coordinates)
        XCTAssertNil(map.displayIcon)
        XCTAssertNil(map.listViewIconTall)
        XCTAssertNil(map.splash)
        XCTAssertNil(map.premierBackgroundImage)
    }
    
    func testMockMapIntegrity() {
        XCTAssertEqual(mockMap.displayName, "Haven")
        XCTAssertEqual(mockMap.uuid, "2bee0dc9-4ffe-519b-1cbd-7fbe763a6047")
        XCTAssertNotNil(mockMap.displayIcon)
        XCTAssertNotNil(mockMap.splash)
        XCTAssertNotNil(mockMap.coordinates)
    }
    
    /// Verifies that Map model safely ignores unmapped API fields like callouts, narrativeDescription, etc.
    func testMapDecoding_ignoresAdditionalFields() throws {
        let data = JSONFixtures.validMapHavenJSON.data(using: .utf8)!
        let map = try jsonDecoder.decode(Map.self, from: data)
        
        XCTAssertEqual(map.displayName, "Haven")
    }
    
    // MARK: - Tier 2: Boundary & Corner Cases
    
    func testMapDecoding_nilDisplayIcon_success() throws {
        let data = JSONFixtures.mapWithoutDisplayIconJSON.data(using: .utf8)!
        let map = try jsonDecoder.decode(Map.self, from: data)
        
        XCTAssertEqual(map.displayName, "The Range")
        XCTAssertNil(map.displayIcon)
        XCTAssertNil(map.coordinates)
        XCTAssertNil(map.premierBackgroundImage)
        XCTAssertNotNil(map.splash)
    }
    
    func testMapDecoding_specialCharactersInCoordinates() throws {
        let data = JSONFixtures.validMapHavenJSON.data(using: .utf8)!
        let map = try jsonDecoder.decode(Map.self, from: data)
        
        XCTAssertEqual(map.coordinates, "27°28'A'N,89°38'WZ'E")
        XCTAssertTrue(map.coordinates?.contains("°") ?? false)
        XCTAssertTrue(map.coordinates?.contains("'") ?? false)
    }
    
    func testMapDecoding_missingDisplayName_throwsError() {
        let data = JSONFixtures.malformedMapMissingDisplayNameJSON.data(using: .utf8)!
        XCTAssertThrowsError(try jsonDecoder.decode(Map.self, from: data)) { error in
            guard case DecodingError.keyNotFound(let key, _) = error else {
                XCTFail("Expected keyNotFound error, got: \(error)")
                return
            }
            XCTAssertEqual(key.stringValue, "displayName")
        }
    }
    
    func testMapDecoding_corruptedData_throwsError() {
        let corruptedData = Data("{ malformed json }".utf8)
        XCTAssertThrowsError(try jsonDecoder.decode(Map.self, from: corruptedData))
    }
    
    func testMapDecoding_fromAPIResponseEnvelope() throws {
        let wrappedJSON = JSONFixtures.wrapInAPIResponse(innerJSON: "[\(JSONFixtures.validMapHavenJSON)]")
        let data = wrappedJSON.data(using: .utf8)!
        let response = try jsonDecoder.decode(APIResponse<[Map]>.self, from: data)
        
        XCTAssertEqual(response.status, 200)
        XCTAssertEqual(response.data.count, 1)
        XCTAssertEqual(response.data.first?.displayName, "Haven")
    }
}

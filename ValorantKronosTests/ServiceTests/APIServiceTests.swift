//
//  APIServiceTests.swift
//  ValorantKronosTests
//

import XCTest
@testable import ValorantKronos

final class APIServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()
        URLProtocol.registerClass(MockURLProtocol.self)
    }
    
    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        MockURLProtocol.reset()
        super.tearDown()
    }
    
    // MARK: - Tier 1: Happy Path & URL Construction
    
    func testAPIService_sharedSingleton_isAvailable() {
        let service = APIService.shared
        XCTAssertNotNil(service)
    }
    
    func testAPIService_languageEnum_allCasesValidLocaleIdentifiers() {
        let expectedLanguages: [Language: String] = [
            .arabic: "ar-AE",
            .german: "de-DE",
            .englishUS: "en-US",
            .spanishES: "es-ES",
            .spanishMX: "es-MX",
            .french: "fr-FR",
            .indonesian: "id-ID",
            .italian: "it-IT",
            .japanese: "ja-JP",
            .korean: "ko-KR",
            .polish: "pl-PL",
            .portuguese: "pt-BR",
            .russian: "ru-RU",
            .thai: "th-TH",
            .turkish: "tr-TR",
            .vietnamese: "vi-VN",
            .chineseCN: "zh-CN",
            .chineseTW: "zh-TW"
        ]
        
        XCTAssertEqual(Language.allCases.count, 18)
        
        for (language, expectedCode) in expectedLanguages {
            XCTAssertEqual(language.rawValue, expectedCode, "Language \(language) rawValue should be \(expectedCode)")
        }
    }
    
    func testAPIService_urlConstruction_defaultLanguageAndParameters() {
        let baseURL = "https://valorant-api.com/v1"
        let endpoint = "agents"
        guard var components = URLComponents(string: "\(baseURL)/\(endpoint)") else {
            XCTFail("Failed to create URLComponents")
            return
        }
        
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "language", value: Language.englishUS.rawValue))
        queryItems.append(URLQueryItem(name: "isPlayableCharacter", value: "true"))
        components.queryItems = queryItems
        
        let constructedURL = components.url?.absoluteString ?? ""
        XCTAssertTrue(constructedURL.contains("https://valorant-api.com/v1/agents"))
        XCTAssertTrue(constructedURL.contains("language=en-US"))
        XCTAssertTrue(constructedURL.contains("isPlayableCharacter=true"))
    }
    
    func testAPIService_successful200Response_decodesPayload() async throws {
        let agentJSON = JSONFixtures.validAgentSovaJSON
        let responseJSON = JSONFixtures.wrapInAPIResponse(innerJSON: "[\(agentJSON)]", status: 200)
        let responseData = responseJSON.data(using: .utf8)!
        
        MockURLProtocol.mockStatusCode = 200
        MockURLProtocol.mockResponseData = responseData
        
        let agents: [Agent] = try await APIService.shared.fetch(endpoint: "agents")
        
        XCTAssertFalse(agents.isEmpty)
        XCTAssertEqual(agents.first?.displayName, "Sova")
        XCTAssertEqual(agents.first?.role?.displayName, "Initiator")
    }
    
    func testAPIService_decodesComplexModelList() async throws {
        let mapJSON = JSONFixtures.validMapHavenJSON
        let responseJSON = JSONFixtures.wrapInAPIResponse(innerJSON: "[\(mapJSON)]", status: 200)
        let responseData = responseJSON.data(using: .utf8)!
        
        MockURLProtocol.mockStatusCode = 200
        MockURLProtocol.mockResponseData = responseData
        
        let maps: [Map] = try await APIService.shared.fetch(endpoint: "maps")
        
        XCTAssertEqual(maps.count, 1)
        XCTAssertEqual(maps.first?.displayName, "Haven")
        XCTAssertEqual(maps.first?.coordinates, "27°28'A'N,89°38'WZ'E")
    }
    
    // MARK: - Tier 2: Boundary & Error Handling
    
    func testAPIService_http400BadRequest_throwsInvalidResponse() async {
        MockURLProtocol.mockStatusCode = 400
        MockURLProtocol.mockResponseData = Data("{\"status\": 400, \"error\": \"Bad Request\"}".utf8)
        
        do {
            let _: [Agent] = try await APIService.shared.fetch(endpoint: "agents")
            XCTFail("Expected APIError.invalidResponse to be thrown")
        } catch let error as APIError {
            guard case .invalidResponse = error else {
                XCTFail("Expected .invalidResponse, got: \(error)")
                return
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testAPIService_http404NotFound_throwsInvalidResponse() async {
        MockURLProtocol.mockStatusCode = 404
        MockURLProtocol.mockResponseData = Data("{\"status\": 404, \"error\": \"Not Found\"}".utf8)
        
        do {
            let _: [Map] = try await APIService.shared.fetch(endpoint: "unknown_endpoint")
            XCTFail("Expected APIError.invalidResponse to be thrown")
        } catch let error as APIError {
            guard case .invalidResponse = error else {
                XCTFail("Expected .invalidResponse, got: \(error)")
                return
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testAPIService_http500InternalError_throwsInvalidResponse() async {
        MockURLProtocol.mockStatusCode = 500
        MockURLProtocol.mockResponseData = Data("{\"status\": 500, \"error\": \"Server Error\"}".utf8)
        
        do {
            let _: [Agent] = try await APIService.shared.fetch(endpoint: "agents")
            XCTFail("Expected APIError.invalidResponse to be thrown")
        } catch let error as APIError {
            guard case .invalidResponse = error else {
                XCTFail("Expected .invalidResponse, got: \(error)")
                return
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testAPIService_http503ServiceUnavailable_throwsInvalidResponse() async {
        MockURLProtocol.mockStatusCode = 503
        MockURLProtocol.mockResponseData = Data("{\"status\": 503, \"error\": \"Service Unavailable\"}".utf8)
        
        do {
            let _: [Agent] = try await APIService.shared.fetch(endpoint: "agents")
            XCTFail("Expected APIError.invalidResponse to be thrown")
        } catch let error as APIError {
            guard case .invalidResponse = error else {
                XCTFail("Expected .invalidResponse, got: \(error)")
                return
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testAPIService_malformedJSON_throwsDecodingFailed() async {
        MockURLProtocol.mockStatusCode = 200
        MockURLProtocol.mockResponseData = Data("{ corrupted: true, json }".utf8)
        
        do {
            let _: [Agent] = try await APIService.shared.fetch(endpoint: "agents")
            XCTFail("Expected APIError.decodingFailed to be thrown")
        } catch let error as APIError {
            guard case .decodingFailed = error else {
                XCTFail("Expected .decodingFailed, got: \(error)")
                return
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testAPIService_emptyDataResponse_throwsDecodingFailed() async {
        MockURLProtocol.mockStatusCode = 200
        MockURLProtocol.mockResponseData = Data()
        
        do {
            let _: [Agent] = try await APIService.shared.fetch(endpoint: "agents")
            XCTFail("Expected APIError.decodingFailed to be thrown")
        } catch let error as APIError {
            guard case .decodingFailed = error else {
                XCTFail("Expected .decodingFailed, got: \(error)")
                return
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testAPIService_networkOfflineError_throwsRequestFailed() async {
        MockURLProtocol.mockError = URLError(.notConnectedToInternet)
        
        do {
            let _: [Agent] = try await APIService.shared.fetch(endpoint: "agents")
            XCTFail("Expected APIError.requestFailed to be thrown")
        } catch let error as APIError {
            guard case .requestFailed(let underlying) = error else {
                XCTFail("Expected .requestFailed, got: \(error)")
                return
            }
            let urlError = underlying as? URLError
            XCTAssertEqual(urlError?.code, .notConnectedToInternet)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testAPIService_networkTimeoutError_throwsRequestFailed() async {
        MockURLProtocol.mockError = URLError(.timedOut)
        
        do {
            let _: [Agent] = try await APIService.shared.fetch(endpoint: "agents")
            XCTFail("Expected APIError.requestFailed to be thrown")
        } catch let error as APIError {
            guard case .requestFailed(let underlying) = error else {
                XCTFail("Expected .requestFailed, got: \(error)")
                return
            }
            let urlError = underlying as? URLError
            XCTAssertEqual(urlError?.code, .timedOut)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

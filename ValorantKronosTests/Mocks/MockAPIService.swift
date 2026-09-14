//
//  MockAPIService.swift
//  ValorantKronosTests
//

import Foundation
@testable import ValorantKronos

/// In-memory mock implementation of API Service for deterministic unit testing.
public final class MockAPIService: APIServiceProtocol {
    
    // MARK: - State Tracking
    
    public private(set) var callCount: Int = 0
    public private(set) var recordedEndpoints: [String] = []
    public private(set) var lastEndpoint: String?
    public private(set) var lastParameters: [String: String]?
    public private(set) var lastLanguage: Language?
    
    // MARK: - Stub Configuration
    
    public var shouldThrowError: Bool = false
    public var errorToThrow: APIError = .invalidResponse
    public var simulatedDelay: TimeInterval = 0.0
    
    public var stubbedAgents: [Agent] = []
    public var stubbedWeapons: [Weapon] = []
    public var stubbedMaps: [Map] = []
    public var customStubData: Any?
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - Reset
    
    public func reset() {
        callCount = 0
        recordedEndpoints.removeAll()
        lastEndpoint = nil
        lastParameters = nil
        lastLanguage = nil
        shouldThrowError = false
        errorToThrow = .invalidResponse
        simulatedDelay = 0.0
        stubbedAgents.removeAll()
        stubbedWeapons.removeAll()
        stubbedMaps.removeAll()
        customStubData = nil
    }
    
    // MARK: - APIServiceProtocol Implementation
    
    public func fetch<T: Decodable>(endpoint: String) async throws -> T {
        try await fetch(endpoint: endpoint, parameters: nil, language: .englishUS)
    }
    
    public func fetch<T: Decodable>(
        endpoint: String,
        parameters: [String: String]?,
        language: Language
    ) async throws -> T {
        callCount += 1
        recordedEndpoints.append(endpoint)
        lastEndpoint = endpoint
        lastParameters = parameters
        lastLanguage = language
        
        if simulatedDelay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        }
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        if let custom = customStubData as? T {
            return custom
        }
        
        if T.self == [Agent].self {
            return stubbedAgents as! T
        }
        
        if T.self == [Weapon].self {
            return stubbedWeapons as! T
        }
        
        if T.self == [Map].self {
            return stubbedMaps as! T
        }
        
        if let firstAgent = stubbedAgents.first as? T {
            return firstAgent
        }
        
        if let firstWeapon = stubbedWeapons.first as? T {
            return firstWeapon
        }
        
        if let firstMap = stubbedMaps.first as? T {
            return firstMap
        }
        
        throw APIError.decodingFailed(
            NSError(
                domain: "MockAPIService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No stub configured for type \(T.self) on endpoint \(endpoint)"]
            )
        )
    }
}

//
//  APIServiceProtocol.swift
//  ValorantKronos
//
//  Created by Teamwork Agent on 2026-09-12.
//

import Foundation

public enum Language: String, CaseIterable {
    case arabic = "ar-AE"
    case german = "de-DE"
    case englishUS = "en-US"
    case spanishES = "es-ES"
    case spanishMX = "es-MX"
    case french = "fr-FR"
    case indonesian = "id-ID"
    case italian = "it-IT"
    case japanese = "ja-JP"
    case korean = "ko-KR"
    case polish = "pl-PL"
    case portuguese = "pt-BR"
    case russian = "ru-RU"
    case thai = "th-TH"
    case turkish = "tr-TR"
    case vietnamese = "vi-VN"
    case chineseCN = "zh-CN"
    case chineseTW = "zh-TW"
}

/// Protocol defining networking operations for the ValorantKronos application.
public protocol APIServiceProtocol: AnyObject {
    /// Fetches and decodes data from the specified API endpoint using default language and no query parameters.
    /// - Parameter endpoint: The relative endpoint path (e.g. "agents", "weapons", "maps").
    /// - Returns: Decoded model of type `T`.
    func fetch<T: Decodable>(endpoint: String) async throws -> T
    
    /// Fetches and decodes data from the specified API endpoint with optional query parameters and language.
    /// - Parameters:
    ///   - endpoint: The relative endpoint path (e.g. "agents").
    ///   - parameters: Optional dictionary of query parameters (e.g. ["isPlayableCharacter": "true"]).
    ///   - language: Desired localization language.
    /// - Returns: Decoded model of type `T`.
    func fetch<T: Decodable>(
        endpoint: String,
        parameters: [String: String]?,
        language: Language
    ) async throws -> T
}

public extension APIServiceProtocol {
    /// Default implementation forwarding to the parameterized fetch with English and nil parameters.
    func fetch<T: Decodable>(endpoint: String) async throws -> T {
        try await fetch(endpoint: endpoint, parameters: nil, language: .englishUS)
    }
    
    /// Convenience overload for specifying parameters while defaulting language to English.
    func fetch<T: Decodable>(endpoint: String, parameters: [String: String]?) async throws -> T {
        try await fetch(endpoint: endpoint, parameters: parameters, language: .englishUS)
    }
}

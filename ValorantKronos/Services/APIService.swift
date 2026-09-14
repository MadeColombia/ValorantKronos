//
//  APIService.swift
//  ValorantKronos
//
//  Created by Ethan Montalvo.
//  Updated for APIServiceProtocol & URLSession dependency injection.
//

import Foundation

public enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case noData
}

extension APIError: Equatable {
    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.requestFailed, .requestFailed):
            return true
        case (.invalidResponse, .invalidResponse):
            return true
        case (.decodingFailed, .decodingFailed):
            return true
        case (.noData, .noData):
            return true
        default:
            return false
        }
    }
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL was invalid."
        case .requestFailed(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid HTTP response from server."
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noData:
            return "No data was returned from the server."
        }
    }
}

// Generic response struct matching the structure of the Valorant API JSON.
public struct APIResponse<T: Decodable>: Decodable {
    public let status: Int
    public let data: T
    
    public init(status: Int, data: T) {
        self.status = status
        self.data = data
    }
}

public class APIService: APIServiceProtocol {
    public static let shared = APIService()
    
    public let baseURL: String
    private let session: URLSession

    public init(session: URLSession = .shared, baseURL: String = "https://valorant-api.com/v1") {
        self.session = session
        self.baseURL = baseURL
    }
    
    public convenience init(configuration: URLSessionConfiguration, baseURL: String = "https://valorant-api.com/v1") {
        let session = URLSession(configuration: configuration)
        self.init(session: session, baseURL: baseURL)
    }

    public func fetch<T: Decodable>(
        endpoint: String,
        parameters: [String: String]? = nil,
        language: Language = .englishUS
    ) async throws -> T {
        guard var urlComponents = URLComponents(string: "\(baseURL)/\(endpoint)") else {
            throw APIError.invalidURL
        }

        var queryItems = urlComponents.queryItems ?? []
        queryItems.append(URLQueryItem(name: "language", value: language.rawValue))

        if let parameters = parameters {
            for (key, value) in parameters {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        }
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw APIError.requestFailed(error)
        }

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        do {
            let apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: data)
            return apiResponse.data
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    public func fetch<T: Decodable>(endpoint: String) async throws -> T {
        try await fetch(endpoint: endpoint, parameters: nil, language: .englishUS)
    }
}

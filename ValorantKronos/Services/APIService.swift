import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
}

enum Language: String, CaseIterable {
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

// This generic response struct matches the structure of the Valorant API JSON.
struct APIResponse<T: Decodable>: Decodable {
    let status: Int
    let data: T
}

class APIService {
    static let shared = APIService()
    private let baseURL = "https://valorant-api.com/v1"
    private let session = URLSession.shared

    func fetch<T: Decodable>(endpoint: String, parameters: [String: String]? = nil, language: Language = .englishUS) async throws -> T {
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
            // This explicitly catches network connection errors.
            throw APIError.requestFailed(error)
        }

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        do {
            // Decode the full APIResponse and then return the nested data.
            let apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: data)
            return apiResponse.data
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}

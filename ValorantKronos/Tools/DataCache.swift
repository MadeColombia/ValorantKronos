import Foundation

final class DataCache {
    static let shared = DataCache()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = caches.appendingPathComponent("ObjectCache")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func cache<T: Encodable>(_ object: T, forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        do {
            let data = try JSONEncoder().encode(object)
            try data.write(to: fileURL)
        } catch {
            print("Failed to cache data: \(error)")
        }
    }
    
    func retrieve<T: Decodable>(forKey key: String) -> T? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Failed to retrieve cached data: \(error)")
            return nil
        }
    }
    
    func cacheDate(forKey key: String) -> Date? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            return attributes[.modificationDate] as? Date
        } catch {
            print("Failed to get cache date: \(error)")
            return nil
        }
    }
    
    func clearCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}

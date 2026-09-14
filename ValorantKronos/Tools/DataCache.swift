//
//  DataCache.swift
//  ValorantKronos
//
//  Created by Ethan Mont on 1/6/25.
//  Hardened for Atomic Persistence in Milestone 2.
//

import Foundation

public final class DataCache {
    public static let shared = DataCache()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = caches.appendingPathComponent("ObjectCache")
        ensureCacheDirectoryExists()
    }
    
    private func ensureCacheDirectoryExists() {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Persistence
    
    /// Atomically persists an Encodable object to disk.
    public func save<T: Encodable>(_ object: T, forKey key: String) {
        ensureCacheDirectoryExists()
        let fileURL = cacheDirectory.appendingPathComponent(key)
        do {
            let data = try JSONEncoder().encode(object)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save cached data for key '\(key)': \(error)")
        }
    }
    
    /// Backward-compatible wrapper calling `save(_:forKey:)`.
    public func cache<T: Encodable>(_ object: T, forKey key: String) {
        save(object, forKey: key)
    }
    
    // MARK: - Retrieval
    
    public func retrieve<T: Decodable>(forKey key: String) -> T? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Failed to retrieve cached data for key '\(key)': \(error)")
            return nil
        }
    }
    
    public func cacheDate(forKey key: String) -> Date? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            return attributes[.modificationDate] as? Date
        } catch {
            print("Failed to get cache date for key '\(key)': \(error)")
            return nil
        }
    }
    
    public func clearCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        ensureCacheDirectoryExists()
    }
}

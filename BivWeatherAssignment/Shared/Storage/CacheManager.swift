import Foundation

/// Base cache manager for handling data persistence
class CacheManager {
    // MARK: - Properties
    static let shared = CacheManager()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    // MARK: - Initialization
    private init() {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("BivWeather")
        createCacheDirectoryIfNeeded()
    }
    
    // MARK: - Private Methods
    private func createCacheDirectoryIfNeeded() {
        guard !fileManager.fileExists(atPath: cacheDirectory.path) else { return }
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Public Methods
    /// Save data to cache
    /// - Parameters:
    ///   - data: The data to save
    ///   - key: The key to save the data under
    func save<T: Encodable>(_ data: T, forKey key: String) throws {
        let url = cacheDirectory.appendingPathComponent(key)
        let data = try JSONEncoder().encode(data)
        try data.write(to: url)
    }
    
    /// Load data from cache
    /// - Parameters:
    ///   - key: The key to load the data from
    ///   - type: The type to decode the data into
    /// - Returns: The decoded data
    func load<T: Decodable>(forKey key: String, type: T.Type) throws -> T {
        let url = cacheDirectory.appendingPathComponent(key)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    /// Remove data from cache
    /// - Parameter key: The key to remove the data for
    func remove(forKey key: String) throws {
        let url = cacheDirectory.appendingPathComponent(key)
        try fileManager.removeItem(at: url)
    }
    
    /// Clear all cached data
    func clearAll() throws {
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        try contents.forEach { url in
            try fileManager.removeItem(at: url)
        }
    }
    
    /// Check if data exists in cache
    /// - Parameter key: The key to check
    /// - Returns: Whether the data exists
    func exists(forKey key: String) -> Bool {
        let url = cacheDirectory.appendingPathComponent(key)
        return fileManager.fileExists(atPath: url.path)
    }
    
    /// Get the URL for a cached file
    /// - Parameter key: The key to get the URL for
    /// - Returns: The URL for the cached file
    func url(forKey key: String) -> URL {
        cacheDirectory.appendingPathComponent(key)
    }
} 

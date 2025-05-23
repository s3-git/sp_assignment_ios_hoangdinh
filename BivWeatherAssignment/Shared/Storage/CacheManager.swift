import Foundation

protocol CacheManagerProtocol {
    func cacheResponse(_ data: Data, forKey key: String, expirationTime: TimeInterval)
    func getCachedResponse(forKey key: String) -> Data?
    func clearRequestCache()
    func removeSpecificCache(forKey key: String)
}
class CacheManager: CacheManagerProtocol {
    // MARK: - Properties
    static let shared = CacheManager()
    private let requestCache: NSCache<NSString, CachedResponse>

    // MARK: - Types
    final class CachedResponse {
        let data: Data
        let timestamp: Date
        let expirationTime: TimeInterval

        init(data: Data, timestamp: Date, expirationTime: TimeInterval) {
            self.data = data
            self.timestamp = timestamp
            self.expirationTime = expirationTime
        }
    }

    // MARK: - Initialization
    private init() {
        requestCache = NSCache<NSString, CachedResponse>()
        requestCache.countLimit = 100 // Limit cache to 100 items
    }

    // MARK: - Request Cache Methods
    func cacheResponse(_ data: Data, forKey key: String, expirationTime: TimeInterval) {
        let cachedResponse = CachedResponse(data: data, timestamp: Date(), expirationTime: expirationTime)
        requestCache.setObject(cachedResponse, forKey: key as NSString)
    }

    func getCachedResponse(forKey key: String) -> Data? {
        guard let cachedResponse = requestCache.object(forKey: key as NSString) else { return nil }

        let now = Date()
        let expirationDate = cachedResponse.timestamp.addingTimeInterval(cachedResponse.expirationTime)

        guard now < expirationDate else {
            requestCache.removeObject(forKey: key as NSString)
            return nil
        }

        return cachedResponse.data
    }

    func clearRequestCache() {
        requestCache.removeAllObjects()
    }
    func removeSpecificCache(forKey key: String) {
        requestCache.removeObject(forKey: key as NSString)
    }
}

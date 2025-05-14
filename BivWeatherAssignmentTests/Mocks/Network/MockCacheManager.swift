//
//  MockCacheManager.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/14/25.
//


import Foundation

/// Mock implementation of CacheManager for testing
final class MockCacheManager: CacheManagerProtocol, MockProtocol {
    
    // MARK: - Properties
    var shouldFail = false
    var mockError: Error = NSError(domain: "MockError", code: -1, userInfo: nil)
    var lastCachedKey: String?
    var lastCachedData: Data?
    var lastCacheExpiration: TimeInterval?
    var clearCacheCalled = false
    
    // MARK: - Mock Data
    private var cache: [String: (data: Data, expiration: Date)] = [:]
    
    // MARK: - CacheManagerProtocol
    func cacheResponse(_ data: Data, forKey key: String, expirationTime: TimeInterval) {
        lastCachedKey = key
        lastCachedData = data
        lastCacheExpiration = expirationTime
        
        if !shouldFail {
            let expirationDate = Date().addingTimeInterval(expirationTime)
            cache[key] = (data, expirationDate)
        }
    }
    
    func getCachedResponse(forKey key: String) -> Data? {
        guard let cached = cache[key] else { return nil }
        
        // Check if cache is expired
        if Date() > cached.expiration {
            cache.removeValue(forKey: key)
            return nil
        }
        
        return cached.data
    }
    
    func clearRequestCache() {
        clearCacheCalled = true
        if !shouldFail {
            cache.removeAll()
        }
    }
    
    func removeSpecificCache(forKey key: String) {
        if !shouldFail {
            cache.removeValue(forKey: key)
        }
    }
    
    // MARK: - Mock Methods
    func setMockCache(_ data: Data, forKey key: String, expirationTime: TimeInterval) {
        let expirationDate = Date().addingTimeInterval(expirationTime)
        cache[key] = (data, expirationDate)
    }
    
    func getCacheExpiration(forKey key: String) -> Date? {
        return cache[key]?.expiration
    }
    
    // MARK: - MockProtocol
    func reset() {
        shouldFail = false
        mockError = NSError(domain: "MockError", code: -1, userInfo: nil)
        lastCachedKey = nil
        lastCachedData = nil
        lastCacheExpiration = nil
        clearCacheCalled = false
        cache.removeAll()
    }
}

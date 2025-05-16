import XCTest
@testable import BivWeatherAssignment

final class CacheManagerTests: XCTestCase {
    // MARK: - Properties
    private var sut: CacheManager!
    
    // MARK: - Test Lifecycle
    override func setUp() {
        super.setUp()
        sut = CacheManager.shared
        sut.clearRequestCache() // Clear cache before each test
    }
    
    override func tearDown() {
        sut.clearRequestCache() // Clear cache after each test
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func testCacheResponseAndRetrieve() {
        // Given
        let testData = "test data".data(using: .utf8)!
        let key = "testKey"
        let expirationTime: TimeInterval = 300 // 5 minutes
        
        // When
        sut.cacheResponse(testData, forKey: key, expirationTime: expirationTime)
        let retrievedData = sut.getCachedResponse(forKey: key)
        
        // Then
        XCTAssertNotNil(retrievedData)
        XCTAssertEqual(retrievedData, testData)
    }
    
    func testCacheExpiration() {
        // Given
        let testData = "test data".data(using: .utf8)!
        let key = "testKey"
        let expirationTime: TimeInterval = 0.1 // 100ms
        
        // When
        sut.cacheResponse(testData, forKey: key, expirationTime: expirationTime)
        
        // Then
        // Wait for cache to expire
        let expectation = XCTestExpectation(description: "Wait for cache expiration")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let expiredData = self.sut.getCachedResponse(forKey: key)
            XCTAssertNil(expiredData, "Data should be expired")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.3)
    }
    
    func testClearCache() {
        // Given
        let testData1 = "test data 1".data(using: .utf8)!
        let testData2 = "test data 2".data(using: .utf8)!
        let key1 = "testKey1"
        let key2 = "testKey2"
        
        // When
        sut.cacheResponse(testData1, forKey: key1, expirationTime: 300)
        sut.cacheResponse(testData2, forKey: key2, expirationTime: 300)
        sut.clearRequestCache()
        
        // Then
        XCTAssertNil(sut.getCachedResponse(forKey: key1))
        XCTAssertNil(sut.getCachedResponse(forKey: key2))
    }
    
    func testRemoveSpecificCache() {
        // Given
        let testData1 = "test data 1".data(using: .utf8)!
        let testData2 = "test data 2".data(using: .utf8)!
        let key1 = "testKey1"
        let key2 = "testKey2"
        
        // When
        sut.cacheResponse(testData1, forKey: key1, expirationTime: 300)
        sut.cacheResponse(testData2, forKey: key2, expirationTime: 300)
        sut.removeSpecificCache(forKey: key1)
        
        // Then
        XCTAssertNil(sut.getCachedResponse(forKey: key1))
        XCTAssertNotNil(sut.getCachedResponse(forKey: key2))
    }
    
    func testCacheOverwrite() {
        // Given
        let initialData = "initial data".data(using: .utf8)!
        let updatedData = "updated data".data(using: .utf8)!
        let key = "testKey"
        
        // When
        sut.cacheResponse(initialData, forKey: key, expirationTime: 300)
        sut.cacheResponse(updatedData, forKey: key, expirationTime: 300)
        
        // Then
        let retrievedData = sut.getCachedResponse(forKey: key)
        XCTAssertNotNil(retrievedData)
        XCTAssertEqual(retrievedData, updatedData)
    }
    
    func testCacheWithDifferentKeys() {
        // Given
        let testData1 = "test data 1".data(using: .utf8)!
        let testData2 = "test data 2".data(using: .utf8)!
        let key1 = "testKey1"
        let key2 = "testKey2"
        
        // When
        sut.cacheResponse(testData1, forKey: key1, expirationTime: 300)
        sut.cacheResponse(testData2, forKey: key2, expirationTime: 300)
        
        // Then
        let retrievedData1 = sut.getCachedResponse(forKey: key1)
        let retrievedData2 = sut.getCachedResponse(forKey: key2)
        
        XCTAssertNotNil(retrievedData1)
        XCTAssertNotNil(retrievedData2)
        XCTAssertEqual(retrievedData1, testData1)
        XCTAssertEqual(retrievedData2, testData2)
    }
    
    func testCacheWithEmptyData() {
        // Given
        let emptyData = Data()
        let key = "testKey"
        
        // When
        sut.cacheResponse(emptyData, forKey: key, expirationTime: 300)
        
        // Then
        let retrievedData = sut.getCachedResponse(forKey: key)
        XCTAssertNotNil(retrievedData)
        XCTAssertEqual(retrievedData?.count, 0)
    }
    
    func testCacheWithSpecialCharacters() {
        // Given
        let testData = "test data".data(using: .utf8)!
        let key = "test/key/with/special@characters"
        
        // When
        sut.cacheResponse(testData, forKey: key, expirationTime: 300)
        
        // Then
        let retrievedData = sut.getCachedResponse(forKey: key)
        XCTAssertNotNil(retrievedData)
        XCTAssertEqual(retrievedData, testData)
    }
} 

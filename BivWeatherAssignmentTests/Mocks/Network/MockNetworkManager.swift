@testable import BivWeatherAssignment
import Combine
import Foundation

final class MockNetworkManager: NetworkManagerProtocol, MockProtocol {
    // MARK: - Properties
    var shouldFail = false
    var mockError: NetworkError = .invalidResponse
    var lastRequest: Endpoint?
    var isRemoveAllCacheCalled = false
    
    // MARK: - Mock Data
    private var mockResponse: Data?
    private let cacheManager: CacheManagerProtocol
    private let networkHelper = NetworkTestHelper.shared
    
    // MARK: - Initialization
    init(cacheManager: CacheManagerProtocol = MockCacheManager()) {
        self.cacheManager = cacheManager
    }
    
    // MARK: - NetworkManagerProtocol
    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, NetworkError> {
        lastRequest = endpoint
        
        if shouldFail {
            return Fail(error: mockError).eraseToAnyPublisher()
        }
        
        // Check cache first if not force refresh
        if endpoint.cacheTime != 0,
           let url = endpoint.asURL(),
           let cachedData = cacheManager.getCachedResponse(forKey: url.absoluteString),
           let decodedData = try? JSONDecoder().decode(T.self, from: cachedData) {
            return Just(decodedData)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
        
        // Return mock response if available
        if let mockData = mockResponse,
           let decodedResponse = try? JSONDecoder().decode(T.self, from: mockData) {
            // Cache the mock response
            if let url = endpoint.asURL() {
                cacheManager.cacheResponse(mockData, forKey: url.absoluteString, expirationTime: endpoint.cacheTime)
            }
            
            return Just(decodedResponse)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
        
        return Fail(error: .invalidResponse).eraseToAnyPublisher()
    }
    
    func clearCache() {
        isRemoveAllCacheCalled = true
        cacheManager.clearRequestCache()
    }
    
    func removeCache(for endpoint: Endpoint) {
        if let url = endpoint.asURL() {
            cacheManager.removeSpecificCache(forKey: url.absoluteString)
        }
    }
    
    // MARK: - Mock Methods
    func setMockResponse(_ type: MockResponseType) {
        switch type {
            case .weather:
                mockResponse = networkHelper.createMockWeatherResponse()
            case .search:
                mockResponse = networkHelper.createMockSearchResponse()
            case .error(let error):
                shouldFail = true
                mockError = error
            case .custom(let data):
                mockResponse = data
        }
    }
    
    // MARK: - MockProtocol
    func reset() {
        shouldFail = false
        mockError = .invalidResponse
        lastRequest = nil
        mockResponse = nil
    }
}

// MARK: - Mock Response Types
enum MockResponseType {
    case weather
    case search
    case error(NetworkError)
    case custom(Data?)
}

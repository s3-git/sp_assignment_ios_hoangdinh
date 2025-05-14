@testable import BivWeatherAssignment
import Combine
import Foundation

/// Mock implementation of NetworkManager for testing
final class MockNetworkManager: NetworkManagerProtocol, MockProtocol {
    // MARK: - Properties
    var shouldFail = false
    var mockError: AppError = .network(.invalidResponse)
    var lastRequest: Endpoint?
    var isRemoveAllCacheCalled = false
    
    // MARK: - Mock Data
    private var mockResponse: Data?
    private let cacheManager: MockCacheManager
    private let networkHelper = NetworkTestHelper.shared
    
    // MARK: - Initialization
    init(cacheManager: MockCacheManager = MockCacheManager()) {
        self.cacheManager = cacheManager
    }
    
    // MARK: - NetworkManagerProtocol
    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, AppError> {
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
                .setFailureType(to: AppError.self)
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
                .setFailureType(to: AppError.self)
                .eraseToAnyPublisher()
        }
        
        return Fail(error: .network(.invalidResponse)).eraseToAnyPublisher()
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
            case .emptySearch:
                mockResponse = networkHelper.createEmptySearchResponse()
        }
    }
    
    // MARK: - MockProtocol
    func reset() {
        shouldFail = false
        mockError = .network(.invalidResponse)
        lastRequest = nil
        mockResponse = nil
        cacheManager.reset()
    }
}

// MARK: - Mock Response Types
enum MockResponseType {
    case weather
    case search
    case error(AppError)
    case custom(Data?)
    case emptySearch
}

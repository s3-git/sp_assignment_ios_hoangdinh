import Combine
import Foundation

final class MockWeatherService: WeatherServiceProtocol, MockProtocol {
    // MARK: - Properties
    var lastSearchQuery: WeatherSearchRequestParameters?
    var forceRefreshCalled = false
    
    private let mockNetworkManager: MockNetworkManager
    
    // MARK: - Initialization
    init(mockNetworkManager: MockNetworkManager) {
        self.mockNetworkManager = mockNetworkManager
    }
        
    // MARK: - WeatherServiceProtocol
    func searchCities(query: WeatherSearchRequestParameters) -> AnyPublisher<[SearchResult]?, NetworkError> {
        lastSearchQuery = query
        
        return mockNetworkManager.request(WeatherRouter.searchCity(query: query))
            .map { (response: SearchModel) in
                response.searchAPI?.result?.compactMap({ $0 })
            }
            .eraseToAnyPublisher()
    }
    
    func getWeather(query: WeatherRequestParameters, forceRefresh: Bool) -> AnyPublisher<WeatherData?, NetworkError> {
        forceRefreshCalled = forceRefresh
        
        return mockNetworkManager.request(WeatherRouter.getWeather(query: query, forceRefresh: forceRefresh))
            .map { (response: WeatherModel) in
                response.data
            }
            .eraseToAnyPublisher()
    }
    
    func clearAllCaches() {
        mockNetworkManager.clearCache()
    }
    
    // MARK: - MockProtocol
    func reset() {
        lastSearchQuery = nil
        forceRefreshCalled = false
        mockNetworkManager.reset()
    }
    
    // MARK: - Mock Response Configuration
    func setMockResponse(_ type: MockResponseType) {
        mockNetworkManager.setMockResponse(type)
    }
} 

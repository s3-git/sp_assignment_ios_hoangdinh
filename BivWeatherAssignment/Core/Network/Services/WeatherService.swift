import Foundation
import Combine

/// Service for handling weather-related API calls
///

final class WeatherServiceImpl: WeatherServiceProtocol {
    // MARK: - Properties
    private let networkManager: NetworkManager

    // MARK: - Initialization
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    // MARK: - Public Methods

    /// Search for cities matching the query
    /// - Parameter query: The search query
    /// - Returns: Publisher emitting array of cities
    func searchCities(query: WeatherSearchRequestParameters) -> AnyPublisher<[SearchResult], NetworkError> {
        networkManager.request(WeatherRouter.searchCity(query: query))
            .map { (response: SearchModel) in
                response.searchAPI?.result?.compactMap({$0}) ?? []
            }
            .eraseToAnyPublisher()
    }

    /// Get weather for a specific city
    /// - Parameter query: get query
    /// - Returns: Publisher emitting weather data
    func getWeather(query: WeatherRequestParameters) -> AnyPublisher<WeatherData, NetworkError> {
        networkManager.request(WeatherRouter.getWeather(query: query))
            .map { (response: WeatherModel) in
                response.data ?? WeatherData()
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Cache Management

    /// Clear all caches
    func clearAllCaches() {
        networkManager.clearCache()
    }
}

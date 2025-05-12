import Foundation
import Combine

/// Service for handling weather-related API calls
final class WeatherService {
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
    func searchCities(query: String) -> AnyPublisher<[City], NetworkError> {
        networkManager.request(WeatherRouter.searchCity(query: query))
            .map { (response: CitySearchResponse) in
                response.searchAPI.result.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }
    
    /// Get weather for a specific city
    /// - Parameter city: The city name
    /// - Returns: Publisher emitting weather data
    func getWeather(for city: String) -> AnyPublisher<Weather, NetworkError> {
        networkManager.request(WeatherRouter.getWeather(city: city))
            .map { (response: WeatherResponse) in
                response.data.currentCondition.first?.toDomain() ?? Weather(
                    temperature: 0,
                    description: "Unknown",
                    humidity: 0,
                    iconUrl: nil,
                    feelsLike: 0
                )
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Cache Management
    
    /// Clear weather cache
    func clearWeatherCache() {
        networkManager.removeCache(for: WeatherRouter.getWeather(city: ""))
    }
    
    /// Clear city search cache
    func clearCitySearchCache() {
        networkManager.removeCache(for: WeatherRouter.searchCity(query: ""))
    }
    
    /// Clear all caches
    func clearAllCaches() {
        networkManager.clearCache()
    }
} 
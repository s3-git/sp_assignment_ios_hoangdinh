import Combine
import Foundation

/// Service for handling weather-related API calls
///

final class WeatherServiceImpl: WeatherServiceProtocol {
    // MARK: - Properties
    private let networkManager: NetworkManagerProtocol

    // MARK: - Initialization
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }

    // MARK: - Public Methods

    /// Search for cities matching the query
    /// - Parameter query: The search query
    /// - Returns: Publisher emitting array of cities
    func searchCities(query: WeatherSearchRequestParameters) -> AnyPublisher<[SearchResult], AppError> {
//        #if DEBUG
//        return self.forceError(.invalidResponse)
//        #else
        
        networkManager.request(WeatherRouter.searchCity(query: query))
            .map { (response: SearchModel) in
                response.searchAPI?.result?.compactMap({ $0 }) ?? []
            }
            .eraseToAnyPublisher()
//        #endif
    }

    /// Get weather for a specific city
    /// - Parameters:
    ///   - query: get query
    ///   - forceRefresh: if true, ignores cache and fetches fresh data
    /// - Returns: Publisher emitting weather data
    func getWeather(query: WeatherRequestParameters, forceRefresh: Bool) -> AnyPublisher<WeatherData, AppError> {
// #if DEBUG
//        return self.forceError(.weatherDataUnavailable)
// #else
        networkManager.request(WeatherRouter.getWeather(query: query, forceRefresh: forceRefresh))
            .map { (response: WeatherModel) in
                response.data ?? WeatherData()
            }
            .eraseToAnyPublisher()
// #endif
    }

    // MARK: - Cache Management

    /// Clear all caches
    func clearAllCaches() {
        networkManager.clearCache()
    }
    
    // MARK: - Debug Methods
    
    /// Force error for testing error handling
    /// - Parameter errorType: Type of error to force
    /// - Returns: Publisher that always fails with specified error
    /// - Note: This method is for debugging purposes only
    // func forceError<T>(_ errorType: DebugErrorType) -> AnyPublisher<T, AppError> {
    //     switch errorType {
    //     case .network:
    //         return Fail(error: AppError.network(.networkError(URLError(.notConnectedToInternet))))
    //             .eraseToAnyPublisher()
    //     case .invalidResponse:
    //         return Fail(error: AppError.network(.invalidResponse))
    //             .eraseToAnyPublisher()
    //     case .httpError:
    //         return Fail(error: AppError.network(.httpError(404)))
    //             .eraseToAnyPublisher()
    //     case .decodingError:
    //         return Fail(error: AppError.network(.decodingError(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid data format")))))
    //             .eraseToAnyPublisher()
    //     case .cacheMiss:
    //         return Fail(error: AppError.cache(.cacheMiss))
    //             .eraseToAnyPublisher()
    //     case .cacheExpired:
    //         return Fail(error: AppError.cache(.cacheExpired))
    //             .eraseToAnyPublisher()
    //     case .invalidCacheData:
    //         return Fail(error: AppError.cache(.invalidCacheData))
    //             .eraseToAnyPublisher()
    //     case .locationNotAvailable:
    //         return Fail(error: AppError.weather(.locationNotAvailable))
    //             .eraseToAnyPublisher()
    //     case .weatherDataUnavailable:
    //         return Fail(error: AppError.weather(.weatherDataUnavailable))
    //             .eraseToAnyPublisher()
    //     case .invalidCoordinates:
    //         return Fail(error: AppError.weather(.invalidCoordinates))
    //             .eraseToAnyPublisher()
    //     }
    // }
}

// MARK: - Debug Types

// /// Types of errors that can be forced for debugging
// enum DebugErrorType {
//     case network
//     case invalidResponse
//     case httpError
//     case decodingError
//     case cacheMiss
//     case cacheExpired
//     case invalidCacheData
//     case locationNotAvailable
//     case weatherDataUnavailable
//     case invalidCoordinates
// }

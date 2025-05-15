import Combine
import Foundation

final class WeatherServiceImpl: WeatherServiceProtocol {
    // MARK: - Properties
    private let networkManager: NetworkManagerProtocol

    // MARK: - Initialization
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }

    // MARK: - Public Methods
    func searchCities(query: WeatherSearchRequestParameters) -> AnyPublisher<[SearchResult]?, NetworkError> {
        networkManager.request(WeatherRouter.searchCity(query: query))
            .map { (response: SearchModel) in
                response.searchAPI?.result?.compactMap({ $0 })
            }
            .eraseToAnyPublisher()
    }

    func getWeather(query: WeatherRequestParameters, forceRefresh: Bool) -> AnyPublisher<WeatherData?, NetworkError> {
        networkManager.request(WeatherRouter.getWeather(query: query, forceRefresh: forceRefresh))
            .map { (response: WeatherModel) in
                response.data
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Cache Management
    func clearAllCaches() {
        networkManager.clearCache()
    }
}

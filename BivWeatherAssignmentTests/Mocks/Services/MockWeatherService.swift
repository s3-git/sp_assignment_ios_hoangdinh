import Combine
import Foundation

/// Mock implementation of WeatherServiceProtocol for testing
final class MockWeatherService: WeatherServiceProtocol, MockProtocol {
    // MARK: - Properties
    var lastSearchQuery: String?
    var forceRefreshCalled = false
    var shouldFail = false
    var mockError: AppError = .network(.invalidResponse)
    
    var mockNetworkManager: MockNetworkManager
    
    init(lastSearchQuery: String? = nil, forceRefreshCalled: Bool = false, shouldFail: Bool = false, mockError: AppError, mockNetworkManager: MockNetworkManager) {
        self.lastSearchQuery = lastSearchQuery
        self.forceRefreshCalled = forceRefreshCalled
        self.shouldFail = shouldFail
        self.mockError = mockError
        self.mockNetworkManager = mockNetworkManager
    }
    
    // MARK: - Mock Data

    private let mockWeatherData: WeatherData = {
        let currentCondition = CurrentCondition(
            observationTime: "2024-03-12 12:00",
            tempC: "20",
            tempF: "68",
            weatherCode: "113",
            weatherIconURL: [WeatherDesc(value: "http://example.com/icon.png")],
            weatherDesc: [WeatherDesc(value: "Sunny")],
            windspeedMiles: "10",
            windspeedKmph: "16",
            winddirDegree: "180",
            winddir16Point: "S",
            precipMM: "0",
            precipInches: "0",
            humidity: "65",
            visibility: "10",
            visibilityMiles: "6",
            pressure: "1013",
            pressureInches: "30",
            cloudcover: "0",
            feelsLikeC: "22",
            feelsLikeF: "72",
            uvIndex: "6"
        )
        
        return WeatherData(
            request: [Request(type: "City", query: "London")],
            nearestArea: [
                NearestArea(
                    areaName: [WeatherDesc(value: "London")],
                    country: [WeatherDesc(value: "UK")],
                    region: [WeatherDesc(value: "Greater London")],
                    latitude: "51.5074",
                    longitude: "-0.1278",
                    population: "8900000",
                    weatherURL: [WeatherDesc(value: "http://example.com/weather")]
                )
            ],
            timeZone: [TimeZone(localtime: "2024-03-12 12:00", utcOffset: "+0", zone: "Europe/London")],
            currentCondition: [currentCondition],
            weather: [],
            climateAverages: []
        )
    }()
    
    // MARK: - WeatherServiceProtocol
    func searchCities(query: WeatherSearchRequestParameters) -> AnyPublisher<[SearchResult], AppError> {
        lastSearchQuery = query.query
        
        if shouldFail {
            return Fail(error: mockError).eraseToAnyPublisher()
        }
        
        return Just([])
            .setFailureType(to: AppError.self)
            .eraseToAnyPublisher()
    }
    
    func getWeather(query: WeatherRequestParameters, forceRefresh: Bool) -> AnyPublisher<WeatherData, AppError> {
        forceRefreshCalled = forceRefresh
        
        if shouldFail {
            return Fail(error: mockError).eraseToAnyPublisher()
        }
        
        return Just(mockWeatherData)
            .setFailureType(to: AppError.self)
            .eraseToAnyPublisher()
    }
    
    func clearAllCaches() {
        // Mock implementation
    }
    
    // MARK: - MockProtocol
    func reset() {
        lastSearchQuery = nil
        forceRefreshCalled = false
        shouldFail = false
    }
} 

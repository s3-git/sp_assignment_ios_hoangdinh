@testable import BivWeatherAssignment
import XCTest

final class WeatherRouterTests: BaseXCTestCase {
    // MARK: - Properties
    private let apiKey = "mock_api_key"
    
    // MARK: - Search City Tests
    func testSearchCityEndpoint() {
        // Given
        
        let query = WeatherSearchRequestParameters(query: "Lond", numOfResults: 10)
        let router = WeatherRouter.searchCity(query: query)
        
        // When
        let url = router.asURL()
        
        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("/search.ashx") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("q=Lond") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("num_of_results=10") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("format=json") ?? false)
    }
    
    // MARK: - Get Weather Tests
    func testGetWeatherEndpoint() {
        // Given
        let coordinates = "51.5074,-0.127"
        let query = WeatherRequestParameters(query: coordinates)
        let router = WeatherRouter.getWeather(query: query, forceRefresh: false)
        
        // When
        let url = router.asURL()
        
        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("/weather.ashx") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("q=\(coordinates)") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("format=json") ?? false)
    }
    
    // MARK: - Cache Time Tests
    func testCacheTimeConfiguration() {
        // Given
        let coordinates = "51.507,-0.1278"
        let searchQuery = WeatherSearchRequestParameters(query: "Londo")
        let weatherQuery = WeatherRequestParameters(query: coordinates)
        
        // When
        let searchRouter = WeatherRouter.searchCity(query: searchQuery)
        let weatherRouterNormal = WeatherRouter.getWeather(query: weatherQuery, forceRefresh: false)
        let weatherRouterForceRefresh = WeatherRouter.getWeather(query: weatherQuery, forceRefresh: true)
        
        // Then
        XCTAssertEqual(searchRouter.cacheTime, 3600) // 1 hour
        XCTAssertEqual(weatherRouterNormal.cacheTime, 60) // 1 minute
        XCTAssertEqual(weatherRouterForceRefresh.cacheTime, 0) // No cache
    }
    
    // MARK: - HTTP Method Tests
    func testHTTPMethods() {
        // Given
        let searchQuery = WeatherSearchRequestParameters(query: "London")
        let weatherQuery = WeatherRequestParameters(query: "51.507,-0.127")
        
        // When
        let searchRouter = WeatherRouter.searchCity(query: searchQuery)
        let weatherRouter = WeatherRouter.getWeather(query: weatherQuery)
        
        // Then
        XCTAssertEqual(searchRouter.method, .get)
        XCTAssertEqual(weatherRouter.method, .get)
    }
    
    // MARK: - Headers Tests
    func testHeaders() {
        // Given
        let searchQuery = WeatherSearchRequestParameters(query: "Londono")
        let router = WeatherRouter.searchCity(query: searchQuery)
        
        // When
        let headers = router.headers
        
        // Then
        XCTAssertEqual(headers["Content-Type"], "application/json")
        XCTAssertEqual(headers["Accept"], "application/json")
    }
    
} 

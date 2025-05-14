@testable import BivWeatherAssignment
import Combine
import XCTest

/// Test suite for WeatherServiceImpl
/// Tests the weather service implementation including search, weather fetching, and caching functionality
final class WeatherServiceImplTests: BaseXCTestCase {
    // MARK: - Properties
    private var mockWeatherService: MockWeatherService!
    private var mockNetworkManager: MockNetworkManager!
    
    // MARK: - Test Setup
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        mockWeatherService = MockWeatherService(mockNetworkManager: mockNetworkManager)
    }
    
    override func tearDown() {
        mockWeatherService = nil
        mockNetworkManager = nil
        super.tearDown()
    }
    
    // MARK: - Search Cities Tests
    func testSearchCities_WhenSuccessful_ShouldReturnMatchingCities() {
        // Given
        let expectation = XCTestExpectation(description: "Search cities success")
        let query = WeatherSearchRequestParameters(query: "London")
        mockNetworkManager.setMockResponse(.search)
        
        // When
        mockWeatherService.searchCities(query: query)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Search should not fail")
                }
                expectation.fulfill()
            }, receiveValue: { results in
                // Then
                XCTAssertFalse(results.isEmpty, "Search results should not be empty")
                XCTAssertEqual(results.first?.areaName?.first?.value, "London", "First result should match search query")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchCities_WhenCityNotFound_ShouldReturnError() {
        // Given
        let expectedError: AppError = .search(.cityNotFound)
        let expectation = XCTestExpectation(description: "Search cities error")
        let query = WeatherSearchRequestParameters(query: "NonexistentCity")
        mockNetworkManager.setMockResponse(.error(expectedError))
        
        // When
        mockWeatherService.searchCities(query: query)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    // Then
                    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription, "Error should match expected error")
                } else {
                    XCTFail("Search should fail with error")
                }
                expectation.fulfill()
            }, receiveValue: { _ in
                XCTFail("Should not receive search results")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Get Weather Tests
    func testGetWeather_WhenSuccessful_ShouldReturnWeatherData() {
        // Given
        let expectation = XCTestExpectation(description: "Get weather success")
        let query = WeatherRequestParameters(query: "51.5074,-0.1278")
        mockNetworkManager.setMockResponse(.weather)
        
        // When
        mockWeatherService.getWeather(query: query, forceRefresh: false)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Weather fetch should not fail")
                }
                expectation.fulfill()
            }, receiveValue: { weatherData in
                // Then
                XCTAssertNotNil(weatherData, "Weather data should not be nil")
                XCTAssertEqual(weatherData.request?.first?.query, "London", "Weather data should match query")
                XCTAssertNotNil(weatherData.currentCondition?.first, "Current conditions should be present")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetWeather_WhenDataUnavailable_ShouldReturnError() {
        // Given
        let expectedError = AppError.weather(.weatherDataUnavailable)
        let expectation = XCTestExpectation(description: "Get weather error")
        let query = WeatherRequestParameters(query: "51.5074,-0.1278")
        mockNetworkManager.setMockResponse(.error(expectedError))
        
        // When
        mockWeatherService.getWeather(query: query, forceRefresh: false)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    // Then
                    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription, "Error should match expected error")
                } else {
                    XCTFail("Weather fetch should fail with error")
                }
                expectation.fulfill()
            }, receiveValue: { _ in
                XCTFail("Should not receive weather data")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Cache Tests
}

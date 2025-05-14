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
    //    func testWeatherCache_WhenWithinCacheTime_ShouldReturnCachedData() {
    //        // Given
    //        let expectation = XCTestExpectation(description: "Get weather from cache")
    //        let query = WeatherRequestParameters(query: "51.5074,-0.1278")
    //        mockNetworkManager.setMockResponse(.weather)
    //
    //        // When
    //        // First call to populate cache
    //        mockWeatherService.getWeather(query: query, forceRefresh: false)
    //            .sink(receiveCompletion: { _ in
    //                // Second call within cache time
    //                self.mockWeatherService.getWeather(query: query, forceRefresh: false)
    //                    .sink(receiveCompletion: { completion in
    //                        if case .failure = completion {
    //                            XCTFail("Weather fetch should not fail")
    //                        }
    //                        expectation.fulfill()
    //                    }, receiveValue: { weatherData in
    //                        // Then
    //                        XCTAssertNotNil(weatherData)
    //                        XCTAssertEqual(self.mockNetworkManager.requestCount, 1, "Should only make one network request")
    //                    })
    //                    .store(in: &self.cancellables)
    //            }, receiveValue: { _ in })
    //            .store(in: &cancellables)
    //
    //        wait(for: [expectation], timeout: 1.0)
    //    }
    //
    //    func testWeatherCache_WhenCacheExpired_ShouldMakeNewRequest() {
    //        // Given
    //        let expectation = XCTestExpectation(description: "Get weather after cache expiry")
    //        let query = WeatherRequestParameters(query: "51.5074,-0.1278")
    //        mockNetworkManager.setMockResponse(.weather)
    //
    //        // When
    //        // First call to populate cache
    //        mockWeatherService.getWeather(query: query, forceRefresh: false)
    //            .sink(receiveCompletion: { _ in
    //                // Simulate cache expiry
    //                Thread.sleep(forTimeInterval: 61) // Cache time is 60 seconds
    //
    //                // Second call after cache expiry
    //                self.mockWeatherService.getWeather(query: query, forceRefresh: false)
    //                    .sink(receiveCompletion: { completion in
    //                        if case .failure = completion {
    //                            XCTFail("Weather fetch should not fail")
    //                        }
    //                        expectation.fulfill()
    //                    }, receiveValue: { weatherData in
    //                        // Then
    //                        XCTAssertNotNil(weatherData)
    //                        XCTAssertEqual(self.mockNetworkManager.requestCount, 2, "Should make two network requests")
    //                    })
    //                    .store(in: &self.cancellables)
    //            }, receiveValue: { _ in })
    //            .store(in: &cancellables)
    //
    //        wait(for: [expectation], timeout: 65.0)
    //    }
    //
    //    func testWeatherCache_WhenForceRefresh_ShouldMakeNewRequest() {
    //        // Given
    //        let expectation = XCTestExpectation(description: "Get weather with force refresh")
    //        let query = WeatherRequestParameters(query: "51.5074,-0.1278")
    //        mockNetworkManager.setMockResponse(.weather)
    //
    //        // When
    //        // First call to populate cache
    //        mockWeatherService.getWeather(query: query, forceRefresh: false)
    //            .sink(receiveCompletion: { _ in
    //                // Second call with force refresh
    //                self.mockWeatherService.getWeather(query: query, forceRefresh: true)
    //                    .sink(receiveCompletion: { completion in
    //                        if case .failure = completion {
    //                            XCTFail("Weather fetch should not fail")
    //                        }
    //                        expectation.fulfill()
    //                    }, receiveValue: { weatherData in
    //                        // Then
    //                        XCTAssertNotNil(weatherData)
    //                        XCTAssertEqual(self.mockNetworkManager.requestCount, 2, "Should make two network requests")
    //                    })
    //                    .store(in: &self.cancellables)
    //            }, receiveValue: { _ in })
    //            .store(in: &cancellables)
    //
    //        wait(for: [expectation], timeout: 1.0)
    //    }
    //
    //    func testWeatherCache_WhenDifferentQueries_ShouldNotUseCache() {
    //        // Given
    //        let expectation = XCTestExpectation(description: "Get weather for different queries")
    //        let query1 = WeatherRequestParameters(query: "51.5074,-0.1278")
    //        let query2 = WeatherRequestParameters(query: "40.7128,-74.0060")
    //        mockNetworkManager.setMockResponse(.weather)
    //
    //        // When
    //        // First call for query1
    //        mockWeatherService.getWeather(query: query1, forceRefresh: false)
    //            .sink(receiveCompletion: { _ in
    //                // Second call for query2
    //                self.mockWeatherService.getWeather(query: query2, forceRefresh: false)
    //                    .sink(receiveCompletion: { completion in
    //                        if case .failure = completion {
    //                            XCTFail("Weather fetch should not fail")
    //                        }
    //                        expectation.fulfill()
    //                    }, receiveValue: { weatherData in
    //                        // Then
    //                        XCTAssertNotNil(weatherData)
    //                        XCTAssertEqual(self.mockNetworkManager.requestCount, 2, "Should make two network requests")
    //                    })
    //                    .store(in: &self.cancellables)
    //            }, receiveValue: { _ in })
    //            .store(in: &cancellables)
    //
    //        wait(for: [expectation], timeout: 1.0)
    //    }
    
    // MARK: - Cache Management Tests
    func testClearAllCaches() {
        // Given
        let expectation = XCTestExpectation(description: "Cache cleared")
        
        // When
        mockWeatherService.clearAllCaches()
        
        // Then
        XCTAssertTrue(mockNetworkManager.isRemoveAllCacheCalled, "clearCache should be called on network manager")
        expectation.fulfill()
        wait(for: [expectation], timeout: 1.0)
    }
    

}

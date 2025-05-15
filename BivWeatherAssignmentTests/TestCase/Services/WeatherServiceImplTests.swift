@testable import BivWeatherAssignment
import Combine
import XCTest

final class WeatherServiceImplTests: BaseXCTestCase {
    // MARK: - Properties
    private var mockWeatherService: WeatherServiceProtocol!
    private var mockNetworkManager: MockNetworkManager!
    
    // MARK: - Test Setup
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        mockWeatherService = WeatherServiceImpl(networkManager: mockNetworkManager)
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
                XCTAssertEqual(results?.first?.areaName?.first?.value, "London", "First result should match search query")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchCities_WhenEmptyResults_ShouldReturnEmptyArray() {
        // Given
        let expectation = XCTestExpectation(description: "Search cities empty results")
        let query = WeatherSearchRequestParameters(query: "NonExistentCity123")
        let mockResponse = networkHelper.createEmptySearchResponse()
        mockNetworkManager.setMockResponse(.custom(mockResponse))
        
        // When
        mockWeatherService.searchCities(query: query)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Search should not fail with empty results")
                }
                expectation.fulfill()
            }, receiveValue: { results in
                // Then
                XCTAssertTrue(results?.isEmpty ?? false, "Search results should be empty")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchCities_WhenNetworkError_ShouldReturnError() {
        // Given
        let expectation = XCTestExpectation(description: "Search cities network error")
        let query = WeatherSearchRequestParameters(query: "LondonReturnError")
        let netWorkErrorExpectation = NetworkError.networkError(URLError(.notConnectedToInternet))
        mockNetworkManager.setMockResponse(.error(netWorkErrorExpectation))
        
        // When
        mockWeatherService.searchCities(query: query)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    // Then
                    XCTAssertEqual(error, netWorkErrorExpectation)
                } else {
                    XCTFail("Search should fail with network error")
                }
                expectation.fulfill()
            }, receiveValue: { _ in
                XCTFail("Should not receive search results")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchCities_WhenResponseIsNil_ShouldReturnEmptyArray() {
        // Given
        let expectation = XCTestExpectation(description: "Search cities nil response")
        let query = WeatherSearchRequestParameters(query: "LondonEmptyArray")
        let mockResponse = networkHelper.createNilSearchResponse()
        
        mockNetworkManager.setMockResponse(.custom(mockResponse))
        
        // When
        mockWeatherService.searchCities(query: query)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Search should not fail with nil response")
                }
                expectation.fulfill()
            }, receiveValue: { results in
                // Then
                
                let expect = results ?? []
                XCTAssertTrue(expect.isEmpty, "Search results should be empty when response is nil")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchCities_WhenSearchAPIResultIsNil_ShouldReturnEmptyArray() {
        // Given
        let expectation = XCTestExpectation(description: "Search cities nil searchAPI result")
        let query = WeatherSearchRequestParameters(query: "LondonNilResult")
        let nilSearchAPIResult = SearchModel(searchAPI: SearchAPI(result: nil))
        let encodedData = try? JSONEncoder().encode(nilSearchAPIResult)
        mockNetworkManager.setMockResponse(.custom(encodedData))
        
        // When
        mockWeatherService.searchCities(query: query)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Search should not fail with nil searchAPI result")
                }
                expectation.fulfill()
            }, receiveValue: { results in
                // Then
                let expect = results ?? []

                XCTAssertTrue(expect.isEmpty, "Search results should be empty when searchAPI result is nil")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Get Weather Tests
    func testGetWeather_WhenSuccessful_ShouldReturnWeatherData() {
        // Given
        let expectation = XCTestExpectation(description: "Get weather success")
        let query = WeatherRequestParameters(query: "51.5071,-0.1278")
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
                XCTAssertNotNil(weatherData?.currentCondition?.first, "Current conditions should be present")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetWeather_WhenEmptyResponse_ShouldReturnEmptyWeatherData() {
        // Given
        let expectation = XCTestExpectation(description: "Get weather empty response")
        let query = WeatherRequestParameters(query: "51.5072,-0.1278")
        let mockResponse = networkHelper.createEmptyWeatherResponse()

        mockNetworkManager.setMockResponse(.custom(mockResponse))
        
        // When
        mockWeatherService.getWeather(query: query, forceRefresh: false)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Weather fetch should not fail with empty response")
                }
                expectation.fulfill()
            }, receiveValue: { weatherData in
                // Then
                XCTAssertNotNil(weatherData, "Weather data should not be nil")
                XCTAssertTrue(weatherData?.currentCondition?.isEmpty ?? false, "Current conditions should be empty")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetWeather_WhenNetworkError_ShouldReturnError() {
        // Given
        let expectation = XCTestExpectation(description: "Get weather network error")
        let query = WeatherRequestParameters(query: "51.5073,-0.1278")
        let expectedError = NetworkError.networkError(URLError(.notConnectedToInternet))

        mockNetworkManager.setMockResponse(.error(expectedError))
        
        // When
        mockWeatherService.getWeather(query: query, forceRefresh: false)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    // Then
                    XCTAssertEqual(error, expectedError)
                } else {
                    XCTFail("Weather fetch should fail with network error")
                }
                expectation.fulfill()
            }, receiveValue: { _ in
                XCTFail("Should not receive weather data")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetWeather_WhenForceRefresh_ShouldIgnoreCache() {
        // Given
        let expectation = XCTestExpectation(description: "Get weather force refresh")
        let query = WeatherRequestParameters(query: "51.5074,-0.1278")
        mockNetworkManager.setMockResponse(.weather)
        
        // When
        mockWeatherService.getWeather(query: query, forceRefresh: true)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Weather fetch should not fail")
                }
                expectation.fulfill()
            }, receiveValue: { weatherData in
                // Then
                XCTAssertNotNil(weatherData, "Weather data should not be nil")
                XCTAssertTrue(self.mockNetworkManager.lastRequest?.cacheTime == 0, "Force refresh should be called")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetWeather_WhenResponseIsNil_ShouldReturnEmptyWeatherData() {
        // Given
        let expectation = XCTestExpectation(description: "Get weather nil response")
        let query = WeatherRequestParameters(query: "51.5075,-0.1278")
        let mockResponse = networkHelper.createNilWeatherResponse()
        mockNetworkManager.setMockResponse(.custom(mockResponse))
        
        // When
        mockWeatherService.getWeather(query: query, forceRefresh: false)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Weather fetch should not fail with nil response")
                }
                expectation.fulfill()
            }, receiveValue: { weatherData in
                // Then
                guard let weatherData else {
                    XCTAssertNotNil(weatherData, "Weather data should not be nil")
                    return
                }
                XCTAssertNil(weatherData.currentCondition, "Current conditions should be nil")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Cache Management Tests
    func testClearAllCaches() {
        // Given
        let expectation = XCTestExpectation(description: "Cache cleared")
        
        // When
        mockWeatherService.clearAllCaches()
        
        // Then
        XCTAssertTrue(mockNetworkManager.isRemoveAllCacheCalled)
        expectation.fulfill()
        wait(for: [expectation], timeout: 1.0)
    }
}

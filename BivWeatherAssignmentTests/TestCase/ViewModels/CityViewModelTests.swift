import XCTest
import Combine
@testable import BivWeatherAssignment

final class CityViewModelTests: BaseXCTestCase {
    // MARK: - Properties
    private var sut: CityViewModel!
    private var mockWeatherService: MockWeatherService!
    private var mockCity: SearchResult!

    // MARK: - Test Setup
    override func setUp() {
        super.setUp()
        mockWeatherService = MockWeatherService(mockNetworkManager: MockNetworkManager())
        mockCity = createMockCity(name: "London")
        sut = CityViewModel(
            city: mockCity,
            navBarHeight: 44,
            weatherService: mockWeatherService
        )
    }
    
    override func tearDown() {
        sut = nil
        mockWeatherService = nil
        mockCity = nil
        super.tearDown()
    }
    
    // MARK: - Weather Data Tests
    func testFetchWeatherData_Success() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch weather success")
        mockWeatherService.setMockResponse(.weather)
        
        // When
        sut.fetchWeatherData()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.state, .success)
            XCTAssertNotNil(self.sut.weatherData)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchWeatherData_Error() {
        // Given
        let errorExpectation = AppError.weather(.weatherDataUnavailable)
        let expectation = XCTestExpectation(description: errorExpectation.localizedDescription)
        mockWeatherService.setMockResponse(.error(errorExpectation))
        
        // When
        sut.fetchWeatherData()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.state, .error(errorExpectation.localizedDescription))
            XCTAssertNil(self.sut.weatherData)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchWeatherData_ForceRefresh() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch weather force refresh")
        mockWeatherService.setMockResponse(.weather)
        
        // When
        sut.fetchWeatherData(forceRefresh: true)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockWeatherService.forceRefreshCalled)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchWeatherData_InvalidCoordinates() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch weather invalid coordinates")
        mockCity = createMockCity(name: "Invalid", latitude: nil, longitude: nil)
        sut = CityViewModel(
            city: mockCity,
            navBarHeight: 44,
            weatherService: mockWeatherService
        )
        
        // When
        sut.fetchWeatherData()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.state, .initial)
            XCTAssertNil(self.sut.weatherData)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - State Management Tests
    func testStateTransitions() {
        // Given
        let expectation = XCTestExpectation(description: "State transitions")
        mockWeatherService.setMockResponse(.weather)
        
        // When
        sut.fetchWeatherData()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.state, .success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helper Methods
    private func createMockCity(name: String, latitude: String? = "51.5074", longitude: String? = "-0.1278") -> SearchResult {
        return SearchResult(
            areaName: [AreaName(value: name)],
            country: [AreaName(value: "Country")],
            region: [AreaName(value: "Region")],
            latitude: latitude,
            longitude: longitude,
            population: "1000000",
            weatherURL: [AreaName(value: "http://example.com")]
        )
    }
} 

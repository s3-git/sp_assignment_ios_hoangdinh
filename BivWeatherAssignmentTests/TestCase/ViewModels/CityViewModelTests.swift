@testable import BivWeatherAssignment
import Combine
import XCTest

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
    func testStateTransitions_Complete() {
        // Given
        let expectation = XCTestExpectation(description: "Complete state transitions")
        expectation.expectedFulfillmentCount = 3 // Initial -> Loading -> Success
        mockWeatherService.setMockResponse(.weather)
        
        // When
        var stateChanges: [ViewState] = []
        sut.$state
            .sink { state in
                stateChanges.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchWeatherData()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(stateChanges.count, 3)
        XCTAssertEqual(stateChanges[0], .initial)
        XCTAssertEqual(stateChanges[1], .loading)
        XCTAssertEqual(stateChanges[2], .success)
    }
    
    func testStateTransitions_Error() {
        // Given
        let expectation = XCTestExpectation(description: "Error state transitions")
        expectation.expectedFulfillmentCount = 3 // Initial -> Loading -> Error
        let error = AppError.weather(.weatherDataUnavailable)
        mockWeatherService.setMockResponse(.error(error))
        
        // When
        var stateChanges: [ViewState] = []
        sut.$state
            .sink { state in
                stateChanges.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchWeatherData()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(stateChanges.count, 3)
        XCTAssertEqual(stateChanges[0], .initial)
        XCTAssertEqual(stateChanges[1], .loading)
        XCTAssertEqual(stateChanges[2], .error(error.localizedDescription))
    }
    
    // MARK: - Weather Data Presentation Tests
    func testWeatherDataPresentation() {
        // Given
        let expectation = XCTestExpectation(description: "Weather data presentation")
        mockWeatherService.setMockResponse(.weather)
        
        // When
        sut.$weatherData
            .dropFirst()
            .sink { weatherData in
                // Then
                XCTAssertNotNil(weatherData)
                
                // Location Information
                XCTAssertNotNil(weatherData?.areaName)
                XCTAssertNotNil(weatherData?.regionName)
                XCTAssertNotNil(weatherData?.countryName)
                XCTAssertNotNil(weatherData?.localTime)
                
                // Current Weather
                XCTAssertNotNil(weatherData?.weatherDesc)
                XCTAssertNotNil(weatherData?.imageURL)
                XCTAssertNotNil(weatherData?.temperature)
                XCTAssertNotNil(weatherData?.feelsLike)
                
                // Atmospheric Conditions
                XCTAssertNotNil(weatherData?.humidity)
                XCTAssertNotNil(weatherData?.pressure)
                XCTAssertNotNil(weatherData?.visibility)
                XCTAssertNotNil(weatherData?.cloudCover)
                XCTAssertNotNil(weatherData?.precipitation)
                
                // Wind Information
                XCTAssertNotNil(weatherData?.windSpeed)
                XCTAssertNotNil(weatherData?.windDirection)
                
                // Additional Weather Info
                XCTAssertNotNil(weatherData?.uvIndex)
                XCTAssertNotNil(weatherData?.observationTime)
                
                // Forecast
                XCTAssertNotNil(weatherData?.forecastDays)
                if let firstForecastDay = weatherData?.forecastDays.first {
                    XCTAssertNotNil(firstForecastDay.date)
                    XCTAssertNotNil(firstForecastDay.maxTemp)
                    XCTAssertNotNil(firstForecastDay.minTemp)
                    XCTAssertNotNil(firstForecastDay.avgTemp)
                    XCTAssertNotNil(firstForecastDay.sunHours)
                    XCTAssertNotNil(firstForecastDay.uvIndex)
                    XCTAssertNotNil(firstForecastDay.sunrise)
                    XCTAssertNotNil(firstForecastDay.sunset)
                    XCTAssertNotNil(firstForecastDay.moonrise)
                    XCTAssertNotNil(firstForecastDay.moonset)
                    XCTAssertNotNil(firstForecastDay.moonPhase)
                    XCTAssertNotNil(firstForecastDay.moonIllumination)
                    XCTAssertNotNil(firstForecastDay.hourlyForecasts)
                    
                    if let firstHourlyForecast = firstForecastDay.hourlyForecasts.first {
                        XCTAssertNotNil(firstHourlyForecast.time)
                        XCTAssertNotNil(firstHourlyForecast.temperature)
                        XCTAssertNotNil(firstHourlyForecast.weatherDesc)
                        XCTAssertNotNil(firstHourlyForecast.weatherIconURL)
                        XCTAssertNotNil(firstHourlyForecast.precipitation)
                        XCTAssertNotNil(firstHourlyForecast.humidity)
                        XCTAssertNotNil(firstHourlyForecast.cloudCover)
                        XCTAssertNotNil(firstHourlyForecast.windSpeed)
                        XCTAssertNotNil(firstHourlyForecast.windDirection)
                        XCTAssertNotNil(firstHourlyForecast.feelsLike)
                        XCTAssertNotNil(firstHourlyForecast.chanceOfRain)
                        XCTAssertNotNil(firstHourlyForecast.chanceOfSnow)
                        XCTAssertNotNil(firstHourlyForecast.visibility)
                        XCTAssertNotNil(firstHourlyForecast.uvIndex)
                    }
                }
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchWeatherData()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Memory Management Tests
    func testMemoryManagement() {
        // Given
        weak var weakSut: CityViewModel?
        
        // When
        autoreleasepool {
            let strongSut = CityViewModel(
                city: mockCity,
                navBarHeight: 44,
                weatherService: mockWeatherService
            )
            weakSut = strongSut
        }
        
        // Then
        XCTAssertNil(weakSut, "ViewModel should be deallocated")
    }
    
    // MARK: - Initialization Tests
    func testInitialization() {
        // Given
        let navBarHeight: CGFloat = 44
        let city = createMockCity(name: "London")
        
        // When
        let viewModel = CityViewModel(
            city: city,
            navBarHeight: navBarHeight,
            weatherService: mockWeatherService
        )
        
        // Then
        XCTAssertEqual(viewModel.navBarHeight, navBarHeight)
        XCTAssertEqual(viewModel.state, .initial)
        XCTAssertNil(viewModel.weatherData)
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

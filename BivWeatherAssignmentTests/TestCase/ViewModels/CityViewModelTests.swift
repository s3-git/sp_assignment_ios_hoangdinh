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
        var stateChanges: [ViewState] = []
        sut.$state
            .sink { state in
                stateChanges.append(state)
                if state == .success {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.fetchWeatherData()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertGreaterThanOrEqual(stateChanges.count, 3, "Should have at least 3 state changes")
        if stateChanges.count >= 3 {
            XCTAssertEqual(stateChanges[0], .initial)
            XCTAssertEqual(stateChanges[1], .loading)
            XCTAssertEqual(stateChanges[2], .success)
        }
        XCTAssertNotNil(sut.weatherData)
    }
    
    func testFetchWeatherData_Error() {
        // Given
        let errorExpectation = NetworkError.invalidResponse
        let expectation = XCTestExpectation(description: errorExpectation.localizedDescription)
        mockWeatherService.setMockResponse(.error(errorExpectation))
        
        // When
        var stateChanges: [ViewState] = []
        sut.$state
            .sink { state in
                stateChanges.append(state)
                if case .error = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.fetchWeatherData()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertGreaterThanOrEqual(stateChanges.count, 3, "Should have at least 3 state changes")
        if stateChanges.count >= 3 {
            XCTAssertEqual(stateChanges[0], .initial)
            XCTAssertEqual(stateChanges[1], .loading)
            XCTAssertEqual(stateChanges[2], .error(errorExpectation.localizedDescription))
        }
        XCTAssertNil(sut.weatherData)
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
    
    // MARK: - Weather Data Validation Tests
    func testWeatherDataValidation() {
        // Given
        let expectation = XCTestExpectation(description: "Weather data validation")
        mockWeatherService.setMockResponse(.weather)
        
        // When
        sut.$weatherData
            .dropFirst()
            .sink { weatherData in
                // Then
                XCTAssertNotNil(weatherData)
                
                // Essential Weather Information
                XCTAssertNotNil(weatherData?.areaName)
                XCTAssertNotNil(weatherData?.temperature)
                XCTAssertNotNil(weatherData?.weatherDesc)
                XCTAssertNotNil(weatherData?.imageURL)
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchWeatherData()
        
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
        XCTAssertGreaterThanOrEqual(stateChanges.count, 3, "Should have at least 3 state changes")
        if stateChanges.count >= 3 {
            XCTAssertEqual(stateChanges[0], .initial)
            XCTAssertEqual(stateChanges[1], .loading)
            XCTAssertEqual(stateChanges[2], .success)
        }
    }
    
    func testStateTransitions_Error() {
        // Given
        let expectation = XCTestExpectation(description: "Error state transitions")
        expectation.expectedFulfillmentCount = 3 // Initial -> Loading -> Error
        let error = NetworkError.invalidResponse
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
        XCTAssertGreaterThanOrEqual(stateChanges.count, 3, "Should have at least 3 state changes")
        if stateChanges.count >= 3 {
            XCTAssertEqual(stateChanges[0], .initial)
            XCTAssertEqual(stateChanges[1], .loading)
            XCTAssertEqual(stateChanges[2], .error(error.localizedDescription))
        }
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
    
    // MARK: - Weather Data Protocol Tests
    func testWeatherData_LocationInfo() {
        // Given
        let expectation = XCTestExpectation(description: "Location info validation")
        mockWeatherService.setMockResponse(.weather)
        
        // When
        sut.$weatherData
            .dropFirst()
            .sink { weatherData in
                // Then
                XCTAssertNotNil(weatherData)
                
                // Location Information
                XCTAssertNotEqual(weatherData?.areaName, "Unknown Area")
                XCTAssertNotEqual(weatherData?.regionName, "Unknown Region")
                XCTAssertNotEqual(weatherData?.countryName, "Unknown Country")
                XCTAssertNotEqual(weatherData?.localTime, "Unknown TimeZone")
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchWeatherData()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testWeatherData_CurrentWeather() {
        // Given
        let expectation = XCTestExpectation(description: "Current weather validation")
        mockWeatherService.setMockResponse(.weather)
        
        // When
        sut.$weatherData
            .dropFirst()
            .sink { weatherData in
                // Then
                XCTAssertNotNil(weatherData)
                
                // Current Weather
                XCTAssertNotEqual(weatherData?.weatherDesc, "Unknown Weather")
                XCTAssertFalse(weatherData?.imageURL.isEmpty ?? true)
                XCTAssertTrue(weatherData?.temperature.contains("°C") ?? false)
                XCTAssertTrue(weatherData?.temperature.contains("°F") ?? false)
                XCTAssertTrue(weatherData?.feelsLike.contains("Feels like") ?? false)
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchWeatherData()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testWeatherData_AtmosphericConditions() {
        // Given
        let expectation = XCTestExpectation(description: "Atmospheric conditions validation")
        mockWeatherService.setMockResponse(.weather)
        
        // When
        sut.$weatherData
            .dropFirst()
            .sink { weatherData in
                // Then
                XCTAssertNotNil(weatherData)
                
                // Atmospheric Conditions
                XCTAssertTrue(weatherData?.humidity.contains("%") ?? false)
                XCTAssertTrue(weatherData?.pressure.contains("mb") ?? false)
                XCTAssertTrue(weatherData?.visibility.contains("km") ?? false)
                XCTAssertTrue(weatherData?.cloudCover.contains("%") ?? false)
                XCTAssertTrue(weatherData?.precipitation.contains("mm") ?? false)
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchWeatherData()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testWeatherData_WindInfo() {
        // Given
        let expectation = XCTestExpectation(description: "Wind info validation")
        mockWeatherService.setMockResponse(.weather)
        
        // When
        sut.$weatherData
            .dropFirst()
            .sink { weatherData in
                // Then
                XCTAssertNotNil(weatherData)
                
                // Wind Information
                XCTAssertTrue(weatherData?.windSpeed.contains("km/h") ?? false)
                XCTAssertTrue(weatherData?.windDirection.contains("(") ?? false)
                XCTAssertTrue(weatherData?.windDirection.contains(")") ?? false)
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchWeatherData()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testWeatherData_AdditionalInfo() {
        // Given
        let expectation = XCTestExpectation(description: "Additional info validation")
        mockWeatherService.setMockResponse(.weather)
        
        // When
        sut.$weatherData
            .dropFirst()
            .sink { weatherData in
                // Then
                XCTAssertNotNil(weatherData)
                
                // Additional Weather Info
                XCTAssertTrue(weatherData?.uvIndex.contains("UV Index") ?? false)
                XCTAssertTrue(weatherData?.observationTime.contains("Observed at") ?? false)
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchWeatherData()
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

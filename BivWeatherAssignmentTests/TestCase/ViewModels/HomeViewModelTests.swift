@testable import BivWeatherAssignment
import Combine
import SwiftUI
import XCTest

final class HomeViewModelTests: BaseXCTestCase {
    // MARK: - Properties
    private var sut: HomeViewModel!
    private var mockWeatherService: MockWeatherService!
    private var mockRecentCitiesService: MockRecentCitiesService!
    private var mockCoordinator: MockCoordinator!
    
    // MARK: - Test Setup
    override func setUp() {
        super.setUp()
        mockWeatherService = MockWeatherService(mockNetworkManager: MockNetworkManager())
        mockRecentCitiesService = MockRecentCitiesService()
        mockCoordinator = MockCoordinator(navigationController: UINavigationController())
        mockCoordinator.start() // Ensure root view controller is set up
        sut = HomeViewModel(
            weatherService: mockWeatherService,
            recentCitiesService: mockRecentCitiesService, 
            coordinator: mockCoordinator
        )
    }
    
    override func tearDown() {
        sut = nil
        mockWeatherService = nil
        mockRecentCitiesService = nil
        mockCoordinator = nil
        super.tearDown()
    }
    
    // MARK: - Search Tests
    func testSearchText_Getter() {
        // Given
        let expectedText = "London"
        
        // When
        sut.searchText = expectedText
        
        // Then
        XCTAssertEqual(sut.searchText, expectedText, "Getter should return the same value as setter")
        
        // Test implicit closure #3
        let expectation = expectation(description: "Search text getter with error")
        let error = NetworkError.invalidResponse
        mockWeatherService.setMockResponse(.error(error))
        
        var stateChanges: [ViewState] = []
        sut.$state
            .dropFirst()
            .sink { state in
                stateChanges.append(state)
                if case .error = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.searchText = "London"
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(stateChanges.count, 2)
        XCTAssertEqual(stateChanges[0], .loading)
        XCTAssertEqual(stateChanges[1], .error(error.localizedDescription))
    }
    
    func testSearchText_Empty() {
        // Given
        let expectation = expectation(description: "Search text empty")
        
        // When
        sut.$showingRecentCities
            .dropFirst()
            .sink { showingRecent in
                // Then
                XCTAssertTrue(showingRecent)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.searchText = ""
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchText_Valid() {
        // Given
        let expectation = expectation(description: "Search text valid")
        mockWeatherService.setMockResponse(.search)
        
        // When
        var stateChanges: [ViewState] = []
        sut.$state
            .dropFirst()
            .sink { state in
                stateChanges.append(state)
                if state == .success {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.$cities
            .dropFirst()
            .sink { cities in
                // Then
                XCTAssertFalse(self.sut.showingRecentCities)
                XCTAssertFalse(cities.isEmpty)
                XCTAssertEqual(cities.first?.areaName?.first?.value, "London")
            }
            .store(in: &cancellables)
        
        sut.searchText = "London"
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(stateChanges.count, 2)
        XCTAssertEqual(stateChanges[0], .loading)
        XCTAssertEqual(stateChanges[1], .success)
    }
    
    func testSearchText_WithEmptyCities() {
        // Given
        let expectation = expectation(description: "Search text with empty cities")
        let mockResponse = networkHelper.createEmptySearchResponse()
        mockWeatherService.setMockResponse(.custom(mockResponse))
        
        // When
        var stateChanges: [ViewState] = []
        sut.$state
            .dropFirst()
            .sink { state in
                stateChanges.append(state)
                if state == .empty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.$cities
            .dropFirst()
            .sink { cities in
                // Then
                XCTAssertTrue(cities.isEmpty)
            }
            .store(in: &cancellables)
        
        sut.searchText = "London"
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(stateChanges.count, 2)
        XCTAssertEqual(stateChanges[0], .loading)
        XCTAssertEqual(stateChanges[1], .empty)
    }
    
    func testSearchText_WithNilCities() {
        // Given
        let expectation = expectation(description: "Search text with nil cities")
        let mockResponse = networkHelper.createNilSearchResponse()
        mockWeatherService.setMockResponse(.custom(mockResponse))
        
        // When
        var stateChanges: [ViewState] = []
        sut.$state
            .dropFirst()
            .sink { state in
                stateChanges.append(state)
                if state == .empty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.$cities
            .dropFirst()
            .sink { cities in
                // Then
                XCTAssertTrue(cities.isEmpty)
            }
            .store(in: &cancellables)
        
        sut.searchText = "London"
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(stateChanges.count, 2)
        XCTAssertEqual(stateChanges[0], .loading)
        XCTAssertEqual(stateChanges[1], .empty)
    }
    
    func testSearchText_TooShort() {
        // Given
        let expectation = expectation(description: "Search text too short")
        
        // When
        sut.$cities
            .dropFirst()
            .sink { cities in
                // Then
                XCTAssertTrue(cities.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.searchText = "L"
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchTextDebouncing() {
        // Given
        let expectation = expectation(description: "Search text debouncing")
        mockWeatherService.setMockResponse(.search)
        
        // When
        var searchCalls = 0
        sut.$cities
            .dropFirst()
            .sink { _ in
                searchCalls += 1
                // Then
                XCTAssertEqual(self.mockWeatherService.lastSearchQuery?.query, "London")
                XCTAssertEqual(searchCalls, 1, "Should only make one API call after debouncing")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Test implicit closure #5 in closure #1
        var stateChanges: [ViewState] = []
        sut.$state
            .dropFirst()
            .sink { state in
                stateChanges.append(state)
            }
            .store(in: &cancellables)
        
        // Simulate rapid user input
        sut.searchText = "L"
        sut.searchText = "Lo"
        sut.searchText = "Lon"
        sut.searchText = "Lond"
        sut.searchText = "Londo"
        sut.searchText = "London"
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(stateChanges.count, 2)
        XCTAssertEqual(stateChanges[0], .loading)
        XCTAssertEqual(stateChanges[1], .success)
    }
    
    // MARK: - Navigation Tests
    func testShowCityDetail() {
        // Given
        let city = createMockCity(name: "London")
        
        // When
        mockCoordinator.showCityDetail(for: city)
        
        // Then
        XCTAssertEqual(mockCoordinator.navigationController.viewControllers.count, 2)
        let pushedVC = mockCoordinator.navigationController.viewControllers.last
        XCTAssertTrue(pushedVC is UIViewController)
        XCTAssertEqual(pushedVC?.title, "London")
    }
    
    // MARK: - Recent Cities Tests
    func testClearAllRecentCities() {
        // Given
        let expectation = expectation(description: "Clear all recent cities")
        let city = createMockCity(name: "London")
        sut.didSelectCity(city)

        // When
        sut.$recentCities
            .dropFirst()
            .sink { cities in
                XCTAssertTrue(cities.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.clearAllRecentCities()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRemoveRecentCity() {
        // Given
        let expectation = expectation(description: "Remove recent city")
        let city = createMockCity(name: "London")
        sut.didSelectCity(city)

        // When
        sut.$recentCities
            .dropFirst()
            .sink { cities in
                XCTAssertTrue(cities.contains(where: { $0.areaName == city.areaName }) == false)
                XCTAssertTrue(cities.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.removeRecentCity(city)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadRecentCities() {
        // Given
        let expectation = expectation(description: "Load recent cities")
        let city1 = createMockCity(name: "London")
        let city2 = createMockCity(name: "Paris")
        mockRecentCitiesService.setMockData([city1, city2])
        
        // When
        sut.$recentCities
            .sink { cities in
                if cities.isEmpty {
                    return
                }
                XCTAssertEqual(cities.count, 2)
                XCTAssertEqual(cities.first?.areaName?.first?.value, "London")
                XCTAssertEqual(cities.last?.areaName?.first?.value, "Paris")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.loadRecentCities()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Error State Tests
    func testSearchErrorStateFlow() {
        // Given
        let expectation = expectation(description: "Error state flow")
        expectation.expectedFulfillmentCount = 2
        let error = NetworkError.invalidResponse
        mockWeatherService.setMockResponse(.error(error))
        
        // When
        var stateChanges: [ViewState] = []
        sut.$state
            .dropFirst()
            .sink { state in
                stateChanges.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.searchText = "London"
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(stateChanges.count, 2)
        XCTAssertEqual(stateChanges[0], .loading)
        XCTAssertEqual(stateChanges[1], .error(error.localizedDescription))
        XCTAssertTrue(sut.cities.isEmpty)
    }
    
    func testEmptySearchResults() {
        // Given
        let expectation = expectation(description: "Empty search results")
        let mockResponse = networkHelper.createEmptySearchResponse()
        mockWeatherService.setMockResponse(.custom(mockResponse))
        
        // When
        var stateChanges: [ViewState] = []
        sut.$state
            .dropFirst()
            .sink { state in
                stateChanges.append(state)
                if state == .empty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.$cities
            .dropFirst()
            .sink { cities in
                XCTAssertTrue(cities.isEmpty)
            }
            .store(in: &cancellables)
        
        sut.searchText = "NonExistentCity"
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(stateChanges.count, 2)
        XCTAssertEqual(stateChanges[0], .loading)
        XCTAssertEqual(stateChanges[1], .empty)
    }
    
    // MARK: - Helper Methods
    private func createMockCity(name: String) -> SearchResult {
        return SearchResult(
            areaName: [AreaName(value: name)],
            country: [AreaName(value: "Country")],
            region: [AreaName(value: "Region")],
            latitude: "0",
            longitude: "0",
            population: "1000000",
            weatherURL: [AreaName(value: "http://example.com")]
        )
    }
} 

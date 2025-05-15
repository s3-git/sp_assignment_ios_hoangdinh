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
        
        // Simulate rapid user input
        sut.searchText = "L"
        sut.searchText = "Lo"
        sut.searchText = "Lon"
        sut.searchText = "Lond"
        sut.searchText = "Londo"
        sut.searchText = "London"
        
        wait(for: [expectation], timeout: 2.0) // Increased timeout to account for debounce delay
    }
    
    func testSearchRemoveDuplicates() {
        // Given
        let expectation = expectation(description: "Remove duplicates")
        mockWeatherService.setMockResponse(.search)
        
        // When
        var searchCalls = 0
        sut.$cities
            .dropFirst()
            .sink { _ in
                searchCalls += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Simulate duplicate search text
        sut.searchText = "London"
        sut.searchText = "London" // Duplicate
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(searchCalls, 1, "Should only make one API call for duplicate search text")
    }
    
    // MARK: - Navigation Tests
    func testShowCityDetail() {
        // Given
        let city = createMockCity(name: "London")
        
        // When
        mockCoordinator.showCityDetail(for: city)
        
        // Then
        // Verify navigation stack
        XCTAssertEqual(mockCoordinator.navigationController.viewControllers.count, 2) // Home + Detail
        
        // Verify the pushed view controller
        let pushedVC = mockCoordinator.navigationController.viewControllers.last
        XCTAssertTrue(pushedVC is UIViewController)
        XCTAssertEqual(pushedVC?.title, "London")
    }
    
    func testShowCityDetailMultipleTimes() {
        // Given
        let cities = ["London", "Paris", "Tokyo"].map { createMockCity(name: $0) }
        
        // When
        cities.forEach { city in
            mockCoordinator.showCityDetail(for: city)
        }
        
        // Then
        // Verify navigation stack
        XCTAssertEqual(mockCoordinator.navigationController.viewControllers.count, 4) // Home + 3 Details
        
        // Verify each view controller in the stack
        let viewControllers = mockCoordinator.navigationController.viewControllers
        XCTAssertGreaterThanOrEqual(viewControllers.count, 2, "Should have at least Home and one detail view")
        
        // Skip the first view controller (Home) and verify the rest
        for (index, city) in cities.enumerated() {
            guard index + 1 < viewControllers.count else {
                XCTFail("Not enough view controllers in stack")
                return
            }
            
            let viewController = viewControllers[index + 1]
            XCTAssertEqual(viewController.title, city.areaName?.first?.value)
        }
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
                // Then - No need for dropFirst() since we want to verify the initial empty state
                if cities.isEmpty {
                    // Initial state
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
    
    func testRecentCitiesOrder() {
        // Given
        let expectation = expectation(description: "Recent cities order")
        let city1 = createMockCity(name: "London")
        let city2 = createMockCity(name: "Paris")
        mockRecentCitiesService.addRecentCity(city1)
        mockRecentCitiesService.addRecentCity(city2)
        
        // When
        sut.$recentCities
            .sink { cities in
                // Then - No need for dropFirst() since we want to verify the initial empty state
                if cities.isEmpty {
                    // Initial state
                    return
                }
                XCTAssertEqual(cities.first?.areaName?.first?.value, "Paris")
                XCTAssertEqual(cities.last?.areaName?.first?.value, "London")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.didSelectCity(city2)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Error State Tests
    func testSearchErrorStateFlow() {
        // Given
        let expectation = expectation(description: "Error state flow")
        expectation.expectedFulfillmentCount = 2 // Loading then Error
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

@testable import BivWeatherAssignment
import Combine
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
        sut = HomeViewModel(
            weatherService: mockWeatherService,
            recentCitiesService: mockRecentCitiesService, coordinator: mockCoordinator
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
        sut.$cities
            .dropFirst()
            .sink { cities in
                // Then
                XCTAssertFalse(self.sut.showingRecentCities)
                XCTAssertFalse(cities.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.searchText = "London"
        
        wait(for: [expectation], timeout: 1.0)
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
        
        wait(for: [expectation], timeout: 1)
    }
    
    // MARK: - Recent Cities Tests
    func testDidSelectCity() {
        // Given
        let expectation = expectation(description: "Did select city")
        let city = createMockCity(name: "London")
        
        // When
        sut.$recentCities
            .dropFirst()
            .sink { cities in
//                XCTAssertTrue(self.mockCoordinator.showCityDetailCalled ?? false)
                XCTAssertEqual(cities.first?.areaName?.first?.value, "London")
                XCTAssertEqual(cities.count, 1)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.didSelectCity(city)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
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
    
    // MARK: - State Management Tests
    func testSearchStateFlow() {
        // Given
        let expectation = expectation(description: "State flow")
        expectation.expectedFulfillmentCount = 2 // Loading then Success
        mockWeatherService.setMockResponse(.search)
        
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
        XCTAssertEqual(stateChanges[1], .success)
        XCTAssertFalse(sut.cities.isEmpty)
    }
    
    func testSearchEmptyStateFlow() {
        // Given
        let expectation = expectation(description: "Empty state flow")
        expectation.expectedFulfillmentCount = 2 // Loading then Empty
        mockWeatherService.setMockResponse(.emptySearch)
        
        // When
        var stateChanges: [ViewState] = []
        sut.$state
            .dropFirst()
            .sink { state in
                stateChanges.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.searchText = "NonexistentCity"
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(stateChanges.count, 2)
        XCTAssertEqual(stateChanges[0], .loading)
        XCTAssertEqual(stateChanges[1], .empty)
        XCTAssertTrue(sut.cities.isEmpty)
    }
    
    func testSearchErrorStateFlow() {
        // Given
        let expectation = expectation(description: "Error state flow")
        expectation.expectedFulfillmentCount = 2 // Loading then Error
        let error = AppError.search(.searchLimitExceeded)
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
    
    func testSearchQueryTransformation() {
        // Given
        let expectation = expectation(description: "Query transformation")
        mockWeatherService.setMockResponse(.search)
        
        // When
        sut.$cities
            .dropFirst()
            .sink { _ in
                // Then - Tests flatMap closure
                XCTAssertEqual(self.mockWeatherService.lastSearchQuery?.query, "London")
                XCTAssertEqual(self.mockWeatherService.lastSearchQuery?.numOfResults, 10)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.searchText = "London"
        
        wait(for: [expectation], timeout: 1.0 + 0.5)
    }
    
    // MARK: - Search Text Tests
    func testSearchTextDebouncing() {
        // Given
        let expectation = expectation(description: "Search text debouncing")
        mockWeatherService.setMockResponse(.search)
        
        // When
        sut.$cities
            .dropFirst()
            .sink { _ in
                // Then
                XCTAssertEqual(self.mockWeatherService.lastSearchQuery?.query, "London")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.searchText = "L"
        sut.searchText = "Lo"
        sut.searchText = "Lon"
        sut.searchText = "Lond"
        sut.searchText = "Londo"
        sut.searchText = "London"
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Memory Management Tests
    func testMemoryManagement() {
        // Given
        weak var weakSut: HomeViewModel?
        
        // When
        autoreleasepool {
            let strongSut = HomeViewModel(
                weatherService: mockWeatherService,
                recentCitiesService: mockRecentCitiesService, coordinator: mockCoordinator
            )
            weakSut = strongSut
        }
        
        // Then
        XCTAssertNil(weakSut, "ViewModel should be deallocated")
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

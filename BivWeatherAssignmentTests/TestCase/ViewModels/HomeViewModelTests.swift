import XCTest
import Combine
@testable import BivWeatherAssignment

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
            recentCitiesService: mockRecentCitiesService
        )
        sut.coordinator = mockCoordinator
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
        let expectation = XCTestExpectation(description: "Search text empty")
        
        // When
        sut.searchText = ""
        
        // Then
        XCTAssertTrue(sut.showingRecentCities)
        expectation.fulfill()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchText_Valid() {
        // Given
        let expectation = XCTestExpectation(description: "Search text valid")
        mockWeatherService.setMockResponse(.search)
        
        // When
        sut.searchText = "London"
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertFalse(self.sut.showingRecentCities)
            XCTAssertFalse(self.sut.cities.isEmpty)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchText_TooShort() {
        // Given
        let expectation = XCTestExpectation(description: "Search text too short")
        
        // When
        sut.searchText = "Lo"
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertTrue(self.sut.cities.isEmpty)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Recent Cities Tests
    func testDidSelectCity() {
        // Given
        let city = createMockCity(name: "London")
        
        // When
        sut.didSelectCity(city)
        
        // Then
        XCTAssertTrue(mockRecentCitiesService.addRecentCityCalled)
        XCTAssertTrue(mockCoordinator.showCityDetailCalled)
        XCTAssertEqual(mockCoordinator.lastCity?.areaName?.first?.value, "London")
    }
    
    func testClearAllRecentCities() {
        // Given
        let city = createMockCity(name: "London")
        sut.didSelectCity(city)
        
        // When
        sut.clearAllRecentCities()
        
        // Then
        XCTAssertTrue(mockRecentCitiesService.clearRecentCitiesCalled)
        XCTAssertTrue(sut.recentCities.isEmpty)
    }
    
    func testRemoveRecentCity() {
        // Given
        let city = createMockCity(name: "London")
        sut.didSelectCity(city)
        
        // When
        sut.removeRecentCity(city)
        
        // Then
        XCTAssertTrue(mockRecentCitiesService.removeRecentCityCalled)
        XCTAssertTrue(sut.recentCities.isEmpty)
    }
    
    // MARK: - Error Handling Tests
    func testSearchError() {
        // Given
        let errorExpactation = AppError.search(.searchLimitExceeded)
        let expectation = XCTestExpectation(description: errorExpactation.localizedDescription)
        mockWeatherService.setMockResponse(.error(errorExpactation))
        
        // When
        sut.searchText = "London"
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertEqual(self.sut.state, .error(errorExpactation.localizedDescription))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
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

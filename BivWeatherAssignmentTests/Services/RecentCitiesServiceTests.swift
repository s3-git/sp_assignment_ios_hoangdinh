@testable import BivWeatherAssignment
import XCTest

final class RecentCitiesServiceTests: XCTestCase {
    // MARK: - Properties
    private var sut: MockRecentCitiesService!
    private var mockUserDefaults: UserDefaults!
    
    // MARK: - Test Setup
    override func setUp() {
        super.setUp()
        // Create a new suite name for testing to avoid affecting real UserDefaults
        mockUserDefaults = UserDefaults(suiteName: #file)
        mockUserDefaults.removePersistentDomain(forName: #file)
        sut = MockRecentCitiesService()
    }
    
    override func tearDown() {
        mockUserDefaults.removePersistentDomain(forName: #file)
        mockUserDefaults = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func testAddRecentCity_ShouldAddCityToTopOfList() {
        // Given
        let city1 = createMockCity(name: "London")
        let city2 = createMockCity(name: "Paris")
        
        // When
        sut.addRecentCity(city1)
        sut.addRecentCity(city2)
        
        // Then
        XCTAssertTrue(sut.addRecentCityCalled)
        let recentCities = sut.getRecentCities()
        XCTAssertEqual(recentCities.count, 2)
        XCTAssertEqual(recentCities[0].areaName?.first?.value, "Paris")
        XCTAssertEqual(recentCities[1].areaName?.first?.value, "London")
    }
    
    func testAddRecentCity_ShouldNotExceedMaxLimit() {
        // Given
        let maxCities = AppConstants.UserInterface.maxRecentCities
        
        // When
        for i in 0..<maxCities + 5 {
            let city = createMockCity(name: "City\(i)")
            sut.addRecentCity(city)
        }
        
        // Then
        XCTAssertTrue(sut.addRecentCityCalled)
        let recentCities = sut.getRecentCities()
        XCTAssertEqual(recentCities.count, maxCities)
        XCTAssertEqual(recentCities.first?.areaName?.first?.value, "City\(maxCities + 4)")
    }
    
    func testAddRecentCity_ShouldRemoveDuplicate() {
        // Given
        let city = createMockCity(name: "London")
        
        // When
        sut.addRecentCity(city)
        sut.addRecentCity(city)
        
        // Then
        XCTAssertTrue(sut.addRecentCityCalled)
        let recentCities = sut.getRecentCities()
        XCTAssertEqual(recentCities.count, 1)
        XCTAssertEqual(recentCities.first?.areaName?.first?.value, "London")
    }
    
    func testRemoveRecentCity_ShouldRemoveSpecificCity() {
        // Given
        let city1 = createMockCity(name: "London")
        let city2 = createMockCity(name: "Paris")
        sut.addRecentCity(city1)
        sut.addRecentCity(city2)
        
        // When
        sut.removeRecentCity(city1)
        
        // Then
        XCTAssertTrue(sut.removeRecentCityCalled)
        let recentCities = sut.getRecentCities()
        XCTAssertEqual(recentCities.count, 1)
        XCTAssertEqual(recentCities.first?.areaName?.first?.value, "Paris")
    }
    
    func testClearRecentCities_ShouldRemoveAllCities() {
        // Given
        let city1 = createMockCity(name: "London")
        let city2 = createMockCity(name: "Paris")
        sut.addRecentCity(city1)
        sut.addRecentCity(city2)
        
        // When
        sut.clearRecentCities()
        
        // Then
        XCTAssertTrue(sut.clearRecentCitiesCalled)
        let recentCities = sut.getRecentCities()
        XCTAssertTrue(recentCities.isEmpty)
    }
    
    func testGetRecentCities_ShouldReturnEmptyArrayWhenNoCities() {
        // When
        let recentCities = sut.getRecentCities()
        
        // Then
        XCTAssertTrue(recentCities.isEmpty)
    }
    
    func testReset_ShouldClearAllState() {
        // Given
        let city = createMockCity(name: "London")
        sut.addRecentCity(city)
        sut.shouldFail = true
        
        // When
        sut.reset()
        
        // Then
        XCTAssertFalse(sut.addRecentCityCalled)
        XCTAssertFalse(sut.removeRecentCityCalled)
        XCTAssertFalse(sut.clearRecentCitiesCalled)
        XCTAssertFalse(sut.shouldFail)
        XCTAssertTrue(sut.getRecentCities().isEmpty)
    }
    
    func testAddRecentCity_ShouldNotAddWhenShouldFail() {
        // Given
        sut.shouldFail = true
        let city = createMockCity(name: "London")
        
        // When
        sut.addRecentCity(city)
        
        // Then
        XCTAssertTrue(sut.addRecentCityCalled)
        XCTAssertTrue(sut.getRecentCities().isEmpty)
    }
    
    func testRemoveRecentCity_ShouldNotRemoveWhenShouldFail() {
        // Given
        let city = createMockCity(name: "London")
        sut.addRecentCity(city)
        sut.shouldFail = true
        
        // When
        sut.removeRecentCity(city)
        
        // Then
        XCTAssertTrue(sut.removeRecentCityCalled)
        XCTAssertEqual(sut.getRecentCities().count, 1)
    }
    
    func testClearRecentCities_ShouldNotClearWhenShouldFail() {
        // Given
        let city = createMockCity(name: "London")
        sut.addRecentCity(city)
        sut.shouldFail = true
        
        // When
        sut.clearRecentCities()
        
        // Then
        XCTAssertTrue(sut.clearRecentCitiesCalled)
        XCTAssertEqual(sut.getRecentCities().count, 1)
    }
    
    // MARK: - Helper Methods
    private func createMockCity(name: String) -> SearchResult {
        return SearchResult(
            areaName: [AreaName(value: name)],
            country: [Country(value: "Country")],
            region: [Region(value: "Region")],
            latitude: "0",
            longitude: "0"
        )
    }
} 

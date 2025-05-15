@testable import BivWeatherAssignment
import XCTest

final class RecentCitiesServiceTests: XCTestCase {
    // MARK: - Properties
    private var sut: RecentCitiesServiceProtocol!
    private var mockUserDefaults: UserDefaults!
    private let recentCitiesKey = "recentCities"
    
    // MARK: - Test Setup
    override func setUp() {
        super.setUp()
        // Create a new suite name for testing to avoid affecting real UserDefaults
        mockUserDefaults = UserDefaults(suiteName: #file)
        mockUserDefaults.removePersistentDomain(forName: #file)
        sut = RecentCitiesServiceImpl(userDefaults: mockUserDefaults)
    }
    
    override func tearDown() {
        mockUserDefaults.removePersistentDomain(forName: #file)
        mockUserDefaults = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    // MARK: - getRecentCities Tests
    
    func testGetRecentCities_ShouldReturnEmptyArrayWhenNoData() {
        // When
        let recentCities = sut.getRecentCities()
        
        // Then
        XCTAssertTrue(recentCities.isEmpty)
    }
    
    func testGetRecentCities_ShouldReturnEmptyArrayWhenInvalidData() {
        // Given
        mockUserDefaults.set("invalid data".data(using: .utf8)!, forKey: recentCitiesKey)
        
        // When
        let recentCities = sut.getRecentCities()
        
        // Then
        XCTAssertTrue(recentCities.isEmpty)
    }
    
    func testGetRecentCities_ShouldReturnSavedCities() {
        // Given
        let cities = [
            createMockCity(name: "London"),
            createMockCity(name: "Paris")
        ]
        saveCities(cities)
        
        // When
        let recentCities = sut.getRecentCities()
        
        // Then
        XCTAssertEqual(recentCities.count, 2)
        XCTAssertEqual(recentCities[0].areaName?.first?.value, "London")
        XCTAssertEqual(recentCities[1].areaName?.first?.value, "Paris")
    }
    
    // MARK: - addRecentCity Tests
    
    func testAddRecentCity_ShouldAddCityToTopOfList() {
        // Given
        let city1 = createMockCity(name: "London")
        let city2 = createMockCity(name: "Paris")
        
        // When
        sut.addRecentCity(city1)
        sut.addRecentCity(city2)
        
        // Then
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
        let recentCities = sut.getRecentCities()
        XCTAssertEqual(recentCities.count, 1)
        XCTAssertEqual(recentCities.first?.areaName?.first?.value, "London")
    }
    
    // MARK: - removeRecentCity Tests
    
    func testRemoveRecentCity_ShouldRemoveSpecificCity() {
        // Given
        let city1 = createMockCity(name: "London")
        let city2 = createMockCity(name: "Paris")
        sut.addRecentCity(city1)
        sut.addRecentCity(city2)
        
        // When
        sut.removeRecentCity(city1)
        
        // Then
        let recentCities = sut.getRecentCities()
        XCTAssertEqual(recentCities.count, 1)
        XCTAssertEqual(recentCities.first?.areaName?.first?.value, "Paris")
    }
    
    func testRemoveRecentCity_ShouldDoNothingWhenCityNotExists() {
        // Given
        let city1 = createMockCity(name: "London")
        let city2 = createMockCity(name: "Paris")
        sut.addRecentCity(city1)
        
        // When
        sut.removeRecentCity(city2)
        
        // Then
        let recentCities = sut.getRecentCities()
        XCTAssertEqual(recentCities.count, 1)
        XCTAssertEqual(recentCities.first?.areaName?.first?.value, "London")
    }
    
    func testRemoveRecentCity_ShouldHandleEncodingError() {
        // Given
        let city = createMockCity(name: "London")
        sut.addRecentCity(city)
        mockUserDefaults.set("invalid data".data(using: .utf8)!, forKey: recentCitiesKey)
        
        // When
        sut.removeRecentCity(city)
        
        // Then
        let recentCities = sut.getRecentCities()
        XCTAssertTrue(recentCities.isEmpty)
    }
    
    // MARK: - clearRecentCities Tests
    
    func testClearRecentCities_ShouldRemoveAllCities() {
        // Given
        let city1 = createMockCity(name: "London")
        let city2 = createMockCity(name: "Paris")
        sut.addRecentCity(city1)
        sut.addRecentCity(city2)
        
        // When
        sut.clearRecentCities()
        
        // Then
        let recentCities = sut.getRecentCities()
        XCTAssertTrue(recentCities.isEmpty)
    }
    
    func testClearRecentCities_ShouldDoNothingWhenNoCities() {
        // When
        sut.clearRecentCities()
        
        // Then
        let recentCities = sut.getRecentCities()
        XCTAssertTrue(recentCities.isEmpty)
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
    
    private func saveCities(_ cities: [SearchResult]) {
        guard let data = try? JSONEncoder().encode(cities) else { return }
        mockUserDefaults.set(data, forKey: recentCitiesKey)
    }
} 

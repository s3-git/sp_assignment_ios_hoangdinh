import Foundation

/// Mock implementation of RecentCitiesServiceProtocol for testing
final class MockRecentCitiesService: RecentCitiesServiceProtocol, MockProtocol {
    // MARK: - Properties
    var addRecentCityCalled = false
    var removeRecentCityCalled = false
    var clearRecentCitiesCalled = false
    var shouldFail = false
    
    // MARK: - Mock Data
    private var mockRecentCities: [SearchResult] = []
    
    // MARK: - RecentCitiesServiceProtocol
    func addRecentCity(_ city: SearchResult) {
        addRecentCityCalled = true
        if !shouldFail {
            mockRecentCities.insert(city, at: 0)
            if mockRecentCities.count > AppConstants.UserInterface.maxRecentCities {
                mockRecentCities.removeLast()
            }
        }
    }
    
    func removeRecentCity(_ city: SearchResult) {
        removeRecentCityCalled = true
        if !shouldFail {
            mockRecentCities.removeAll { $0.areaName == city.areaName }
        }
    }
    
    func clearRecentCities() {
        clearRecentCitiesCalled = true
        if !shouldFail {
            mockRecentCities.removeAll()
        }
    }
    
    func getRecentCities() -> [SearchResult] {
        return mockRecentCities
    }
    
    // MARK: - MockProtocol
    func reset() {
        addRecentCityCalled = false
        removeRecentCityCalled = false
        clearRecentCitiesCalled = false
        shouldFail = false
        mockRecentCities.removeAll()
    }
} 

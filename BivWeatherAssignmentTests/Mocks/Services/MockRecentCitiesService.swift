@testable import BivWeatherAssignment
import Foundation

/// Mock implementation of RecentCitiesServiceProtocol for testing
final class MockRecentCitiesService: RecentCitiesServiceProtocol, MockProtocol {
    // MARK: - Properties
    var shouldFail = false
    let maxRecentCities = AppConstants.UserInterface.maxRecentCities
    
    // MARK: - Mock Data
    private var mockRecentCities: [SearchResult] = []
    
    // MARK: - RecentCitiesServiceProtocol
    func addRecentCity(_ city: SearchResult) {
            
        // Remove if city already exists to avoid duplicates
        mockRecentCities.removeAll { $0.areaName?.first?.value == city.areaName?.first?.value }
        
        if !shouldFail {
            // Add new city at the beginning
            mockRecentCities.insert(city, at: 0)
            
            // Keep only the most recent cities
            if mockRecentCities.count > maxRecentCities {
                mockRecentCities = Array(mockRecentCities.prefix(maxRecentCities))
            }
        }
    }
    
    func removeRecentCity(_ city: SearchResult) {
        if !shouldFail {
            mockRecentCities.removeAll { $0.areaName?.first?.value == city.areaName?.first?.value }
        }
    }
    
    func clearRecentCities() {
        if !shouldFail {
            mockRecentCities.removeAll()
        }
    }
    
    func getRecentCities() -> [SearchResult] {
        return mockRecentCities
    }
    
    // MARK: - MockProtocol
    func reset() {
        shouldFail = false
        mockRecentCities.removeAll()
    }
    
    // MARK: - Test Helpers
    /// Set mock data for testing
    /// - Parameter cities: Array of cities to set as mock data
    func setMockData(_ cities: [SearchResult]) {
        mockRecentCities = cities
    }
    
    /// Get current mock data count
    /// - Returns: Number of cities in mock data
    func getMockDataCount() -> Int {
        return mockRecentCities.count
    }
} 

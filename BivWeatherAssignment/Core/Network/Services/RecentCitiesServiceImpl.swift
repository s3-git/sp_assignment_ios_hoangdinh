import Foundation

/// Service for managing recently viewed cities
final class RecentCitiesServiceImpl: RecentCitiesServiceProtocol {
    // MARK: - Properties
    private let userDefaults: UserDefaults
    private let maxRecentCities = AppConstants.UserInterface.maxRecentCities
    private let recentCitiesKey = "recentCities"

    // MARK: - Initialization
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Public Methods
    /// Add a city to recent cities list
    /// - Parameter city: The city to add
    func addRecentCity(_ city: SearchResult) {
        var recentCities = getRecentCities()

        // Remove if city already exists to avoid duplicates
        recentCities.removeAll { $0.areaName?.first?.value == city.areaName?.first?.value }

        // Add new city at the beginning
        recentCities.insert(city, at: 0)

        // Keep only the most recent cities
        if recentCities.count > maxRecentCities {
            recentCities = Array(recentCities.prefix(maxRecentCities))
        }

        // Save to UserDefaults
        save(recentCities)
    }

    /// Get list of recent cities
    /// - Returns: Array of recent cities
    func getRecentCities() -> [SearchResult] {
        guard let data = userDefaults.data(forKey: recentCitiesKey),
              let cities = try? JSONDecoder().decode([SearchResult].self, from: data) else {
            return []
        }
        return cities
    }

    /// Clear all recent cities
    func clearRecentCities() {
        userDefaults.removeObject(forKey: recentCitiesKey)
    }
    
    /// Remove a specific city from recent cities list
    /// - Parameter city: The city to remove
    /// - Note: This will remove the city if it exists in the list
    func removeRecentCity(_ city: SearchResult) {
        var recentCities = getRecentCities()
        
        // Remove the city if it exists
        recentCities.removeAll { $0.areaName?.first?.value == city.areaName?.first?.value }
        
        // Save updated list
        save(recentCities)
    }

    // MARK: - Private Methods
    /// Save cities to UserDefaults
    /// - Parameter cities: Array of cities to save
    private func save(_ cities: [SearchResult]) {
        guard let data = try? JSONEncoder().encode(cities) else { return }
        userDefaults.set(data, forKey: recentCitiesKey)
    }
}

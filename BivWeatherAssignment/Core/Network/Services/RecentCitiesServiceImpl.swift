import Foundation

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
    func addRecentCity(_ city: SearchResult) {
        var recentCities = getRecentCities()

        recentCities.removeAll { $0 == city }

        recentCities.insert(city, at: 0)

        if recentCities.count > maxRecentCities {
            recentCities = Array(recentCities.prefix(maxRecentCities))
        }

        save(recentCities)
    }

    func getRecentCities() -> [SearchResult] {
        guard let data = userDefaults.data(forKey: recentCitiesKey),
              let cities = try? JSONDecoder().decode([SearchResult].self, from: data) else {
            return []
        }
        return cities
    }

    func clearRecentCities() {
        userDefaults.removeObject(forKey: recentCitiesKey)
    }
    
    func removeRecentCity(_ city: SearchResult) {
        var recentCities = getRecentCities()
        
        // Remove the city if it exists
        recentCities.removeAll { $0 == city }
        
        // Save updated list
        save(recentCities)
    }

    // MARK: - Private Methods
    private func save(_ cities: [SearchResult]) {
        guard let data = try? JSONEncoder().encode(cities) else { return }
        userDefaults.set(data, forKey: recentCitiesKey)
    }
}

//
//  RecentCitiesServicesProtocol.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/12/25.
//

protocol RecentCitiesServiceProtocol {
    // MARK: - Public Methods
    /// Add a city to recent cities list
    /// - Parameter city: The city to add
    func addRecentCity(_ city: SearchResult)

    /// Get list of recent cities
    /// - Returns: Array of recent cities
    func getRecentCities() -> [SearchResult]

    /// Clear all recent cities
    func clearRecentCities()
    
    /// Remove a specific city from recent cities list
    /// - Parameter city: The city to remove
    /// - Note: This will remove the city if it exists in the list
    func removeRecentCity(_ city: SearchResult)
}

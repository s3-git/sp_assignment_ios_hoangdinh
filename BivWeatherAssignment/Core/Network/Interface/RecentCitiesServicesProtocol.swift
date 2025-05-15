//
//  RecentCitiesServicesProtocol.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/12/25.
//

protocol RecentCitiesServiceProtocol {
    // MARK: - Public Methods
    func addRecentCity(_ city: SearchResult)

    func getRecentCities() -> [SearchResult]

    func clearRecentCities()
    
    func removeRecentCity(_ city: SearchResult)
}

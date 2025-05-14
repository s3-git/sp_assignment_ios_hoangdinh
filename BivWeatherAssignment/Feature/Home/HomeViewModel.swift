//
//  HomeViewModel.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/12/25.
//

import Combine
import Foundation
import SwiftUI

/// ViewModel for Home screen that manages:
/// - City search functionality with debouncing
/// - Recent cities list management
/// - Navigation to city details
/// - Empty state handling
final class HomeViewModel: BaseViewModel {
    // MARK: - Dependencies
    /// Service for weather-related API calls
    private let weatherService: WeatherServiceProtocol

    /// Service for managing recently viewed cities persistence
    private let recentCitiesService: RecentCitiesServiceProtocol

    /// Coordinator for handling navigation
    weak var coordinator: Coordinator?

    // MARK: - Private Properties
    /// Subject for handling search text changes with debouncing
    private let searchSubject = PassthroughSubject<String, Never>()

    /// Backing property for searchText to avoid publisher loops
    private var _searchText: String

    /// Last successful search query for retry operations
    private var lastSearchQuery: String?

    // MARK: - Published Properties
    /// List of cities matching the current search query
    @Published var cities: [SearchResult]

    /// List of recently viewed cities, ordered by most recent first
    @Published var recentCities: [SearchResult]

    /// Flag indicating whether to show recent cities or search results
    /// - true: Show recent cities
    /// - false: Show search results
    @Published var showingRecentCities: Bool

    // MARK: - Initialization
    /// Initialize the HomeViewModel with required dependencies
    /// - Parameters:
    ///   - weatherService: Service for weather-related API calls
    ///   - recentCitiesService: Service for managing recently viewed cities
    ///   - errorHandler: Service for handling errors
    init(weatherService: WeatherServiceProtocol = WeatherServiceImpl(),
         recentCitiesService: RecentCitiesServiceProtocol = RecentCitiesService(),
         errorHandler: ErrorHandlingServiceProtocol = ErrorHandlingService()) {
        self.weatherService = weatherService
        self.recentCitiesService = recentCitiesService
        self.cities = []
        self.recentCities = []
        self._searchText = ""
        self.showingRecentCities = true
        super.init(initialState: .initial, errorHandler: errorHandler)
        loadRecentCities()
    }

    // MARK: - Public Methods
    /// Current search text with automatic mode switching
    /// - When empty: Shows recent cities
    /// - When not empty: Shows search results
    var searchText: String {
        get { _searchText }
        set {
            _searchText = newValue
            showingRecentCities = newValue.isEmpty
            searchSubject.send(newValue)
        }
    }

    /// Handle city selection
    /// - Parameter city: The selected city
    /// - Note: This will:
    ///   1. Add the city to recent cities
    ///   2. Update the recent cities list
    ///   3. Navigate to city details
    func didSelectCity(_ city: SearchResult) {
        recentCitiesService.addRecentCity(city)
        loadRecentCities()
        coordinator?.showCityDetail(for: city)
    }

    /// Clear all recent cities
    /// - Note: This will:
    ///   1. Remove all cities from persistence
    ///   2. Update the recent cities list
    func clearAllRecentCities() {
        recentCitiesService.clearRecentCities()
        loadRecentCities()
    }

    /// Remove a specific city from recent cities
    /// - Parameter city: The city to remove
    /// - Note: This will:
    ///   1. Remove the city from persistence
    ///   2. Update the recent cities list
    func removeRecentCity(_ city: SearchResult) {
        recentCitiesService.removeRecentCity(city)
        loadRecentCities()
    }

    // MARK: - Private Methods
    /// Load recently viewed cities from persistence
    private func loadRecentCities() {
        recentCities = recentCitiesService.getRecentCities()
    }

    /// Setup reactive bindings for search functionality
    /// - Note: Implements:
    ///   - 500ms debounce for search
    ///   - Empty query handling
    ///   - Error handling
    override func setupBindings() {
        // Search binding
        searchSubject
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .handleEvents(receiveOutput: { [weak self] query in
                self?.state = .loading
                self?.lastSearchQuery = query
            })
            .flatMap { [weak self] query -> AnyPublisher<[SearchResult], AppError> in
                guard let self = self else {
                    return Just([])
                        .setFailureType(to: AppError.self)
                        .eraseToAnyPublisher()
                }

                // Return empty results for empty query or query shorter than minimum length
                guard !query.isEmpty, query.count >= AppConstants.Validation.minSearchLength else {
                    return Just([])
                        .setFailureType(to: AppError.self)
                        .eraseToAnyPublisher()
                }

                let searchQuery = WeatherSearchRequestParameters(query: query, numOfResults: 10)
                return self.weatherService.searchCities(query: searchQuery)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                weak: self,
                receiveValue: { [weak self] _, cities in
                    self?.state = cities.isEmpty ? .empty : .success
                    self?.cities = cities
                },
                receiveCompletion: { [weak self] _, completion in
                    if case .failure(let error) = completion {
                        self?.state = .error(error.localizedDescription)
                    }
                }
            )
            .store(in: &cancellables)
    }
}

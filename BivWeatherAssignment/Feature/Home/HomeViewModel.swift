//
//  HomeViewModel.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/12/25.
//

import Foundation
import Combine
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
        do {
            try recentCitiesService.addRecentCity(city)
            loadRecentCities()
            coordinator?.showCityDetail(for: city)
        } catch {
            handleError(error)
        }
    }

    // MARK: - Private Methods
    /// Load recently viewed cities from persistence
    private func loadRecentCities() {
        do {
            recentCities = try recentCitiesService.getRecentCities()
        } catch {
            handleError(error)
            recentCities = []
        }
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
            .flatMap { [weak self] query -> AnyPublisher<[SearchResult], NetworkError> in
                guard let self = self, !query.isEmpty else {
                    return Just([])
                        .setFailureType(to: NetworkError.self)
                        .eraseToAnyPublisher()
                }

                // Validate search query
                guard query.count >= AppConstants.Validation.minSearchLength else {
                    return Fail(error: NetworkError.custom(AppError.invalidSearchQuery))
                        .eraseToAnyPublisher()
                }

                let searchQuery = WeatherSearchRequestParameters(query: query, numOfResults: 10)
                return self.weatherService.searchCities(query: searchQuery)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                weak: self,
                receiveValue: { [weak self] _, cities in
                    if cities.isEmpty {
                        self?.handleError(AppError.cityNotFound)
                    } else {
                        self?.cities = cities
                        self?.state = .success
                    }
                },
                receiveCompletion: { [weak self] _, completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                }
            )
            .store(in: &cancellables)
    }

    override func retryLastOperation() {
        if let query = lastSearchQuery, !query.isEmpty {
            searchText = query
        } else {
            loadRecentCities()
        }
    }
}

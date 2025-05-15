//
//  HomeViewModel.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/12/25.
//

import Combine
import Foundation
import SwiftUI

final class HomeViewModel: BaseViewModel {
    // MARK: - Dependencies
    
    private let weatherService: WeatherServiceProtocol
    
    private let recentCitiesService: RecentCitiesServiceProtocol
    
    private let coordinator: Coordinator
    
    // MARK: - Private Properties
    
    private let searchSubject = PassthroughSubject<String, Never>()
    
    private var _searchText: String
    
    // MARK: - Published Properties
    
    @Published var cities: [SearchResult]
    
    @Published var recentCities: [SearchResult]
    
    @Published var showingRecentCities: Bool
    
    // MARK: - Initialization
    
    init(weatherService: WeatherServiceProtocol = WeatherServiceImpl(), recentCitiesService: RecentCitiesServiceProtocol = RecentCitiesServiceImpl(), coordinator: Coordinator) {
        self.weatherService = weatherService
        self.recentCitiesService = recentCitiesService
        self.coordinator = coordinator
        self.cities = []
        self.recentCities = []
        self._searchText = ""
        self.showingRecentCities = true
        super.init(initialState: .initial)
        loadRecentCities()
    }
    // MARK: - Public Methods
    
    var searchText: String {
        get { _searchText }
        set {
            _searchText = newValue
            showingRecentCities = newValue.isEmpty
            searchSubject.send(newValue)
        }
    }
    
    func didSelectCity(_ city: SearchResult) {
        recentCitiesService.addRecentCity(city)
        loadRecentCities()
        coordinator.showCityDetail(for: city)
    }
    
    func clearAllRecentCities() {
        recentCitiesService.clearRecentCities()
        loadRecentCities()
    }
    
    func removeRecentCity(_ city: SearchResult) {
        recentCitiesService.removeRecentCity(city)
        loadRecentCities()
    }
    
    func loadRecentCities() {
        recentCities = recentCitiesService.getRecentCities()
    }
    
    override func setupBindings() {
        // Search binding
        searchSubject
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.state = .loading
            })
            .flatMap { [weak self] query -> AnyPublisher<[SearchResult]?, NetworkError> in
                
                // Return empty results for empty query or query shorter than minimum length
                guard let self = self,!query.isEmpty, query.count >= AppConstants.Validation.minSearchLength else {
                    return Just([])
                        .setFailureType(to: NetworkError.self)
                        .eraseToAnyPublisher()
                }
                
                let searchQuery = WeatherSearchRequestParameters(query: query, numOfResults: 10)
                return self.weatherService.searchCities(query: searchQuery)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                weak: self,
                receiveValue: { [weak self] _, cities in
                    self?.state = (cities?.isEmpty ?? true) ? .empty : .success
                    self?.cities = cities ?? []
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

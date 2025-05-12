//
//  HomeViewModel.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/12/25.
//

import Foundation
import Combine
import SwiftUI

/// ViewModel for Home screen
final class HomeViewModel: BaseViewModel {
    // MARK: - Dependencies
    private let weatherService: WeatherServiceProtocol
    weak var coordinator: Coordinator?

    // MARK: - Private Properties
    private let searchSubject = PassthroughSubject<String, Never>()
    private let citySelectionSubject = PassthroughSubject<SearchResult, Never>()
    private var _searchText: String

    // MARK: - Initialization
    init(weatherService: WeatherServiceProtocol = WeatherServiceImpl()) {
        self.weatherService = weatherService

        self.cities = []
        self._searchText = ""
        super.init(initialState: .initial)
    }

    // MARK: - Public Methods
    var searchText: String {
        get { _searchText }
        set {
            _searchText = newValue
            searchSubject.send(newValue)
        }
    }

    @Published var cities: [SearchResult]

    func didSelectCity(_ city: SearchResult) {
        coordinator?.showCityDetail(for: city)
    }

    // MARK: - Private Methods
    override func setupBindings() {
        // Search binding
        searchSubject
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.state = .loading
            })
            .flatMap { [weak self] query -> AnyPublisher<[SearchResult], NetworkError> in
                guard let self = self else {
                    return Fail(error: NetworkError.networkError(URLError(.unknown)))
                        .eraseToAnyPublisher()
                }
                let searchQuery = WeatherSearchRequestParameters(query: query, numOfResults: 10)
                return self.weatherService.searchCities(query: searchQuery)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                weak: self,
                receiveValue: { [weak self] _, cities in
                    self?.cities = cities
                    self?.state = .success
                },
                receiveCompletion: { [weak self] _, completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                }
            )
            .store(in: &cancellables)
    }
}

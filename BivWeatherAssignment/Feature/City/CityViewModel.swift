import Combine
import Foundation
import SwiftUI

// MARK: - CityViewModel
final class CityViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var weatherData: WeatherData?
    let city: SearchResult
    // MARK: - Private Properties
    
    private let weatherService: WeatherServiceProtocol
    private let cacheExpiryInterval: TimeInterval = 60 // 1 minute cache
    var navBarHeight: CGFloat = 0

    // MARK: - Initialization
    init(city: SearchResult, navBarHeight: CGFloat, weatherService: WeatherServiceProtocol = WeatherServiceImpl()) {
        self.navBarHeight = navBarHeight
        self.city = city
        self.weatherService = weatherService
        super.init(initialState: .initial)
    }
    
    // MARK: - Public Methods
    func fetchWeatherData(forceRefresh: Bool = false) {
        guard let name = city.areaName?.first?.value else { return }
        state = .loading
        let getWeatherQuery = WeatherRequestParameters(query: name)
        weatherService.getWeather(query: getWeatherQuery, forceRefresh: forceRefresh)
            .receive(on: DispatchQueue.main)
            .sink(weak: self,
                  receiveValue: { [weak self] _, data in
                self?.weatherData = data
                self?.state = .success
            }, receiveCompletion: { viewModel, completion in
                if case .failure(let error) = completion {
                    viewModel.handleError(error)
                }
            })
            .store(in: &cancellables)
    }
}

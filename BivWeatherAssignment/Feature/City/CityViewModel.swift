import Foundation
import Combine
import SwiftUI

extension WeatherData: WeatherPresenterProtocol {

    var areaName: String {
        self.nearestArea?.first?.areaName?.first?.value ?? "Unknow Area"
    }

    var weatherDesc: String {
        self.currentCondition?.first?.weatherDesc?.first?.value ?? "Unknow Weather"
    }

    var regionName: String {
        self.nearestArea?.first?.region?.first?.value ?? "Unknow Region"
    }

    var countryName: String {
        self.nearestArea?.first?.country?.first?.value ?? "Unknow Country"

    }

    var localTime: String {
        self.timeZone?.first?.localtime ?? "Unknow TimeZone"

    }

    var imageURL: String {
        self.currentCondition?.first?.weatherIconURL?.first?.value ?? ""
    }

    var temperature: String {
        "\(self.currentCondition?.first?.tempC ?? "Unknow")°C,\(self.currentCondition?.first?.tempF ?? "Unknow")°F"
    }

    var humidity: String {
        "\(self.currentCondition?.first?.humidity ?? "Unknow")%"
    }

}
/// ViewModel for managing city weather data
final class CityViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var weatherData: (any WeatherPresenterProtocol)?

    // MARK: - Private Properties
    private let city: SearchResult
    private let weatherService: WeatherServiceProtocol
    private var lastFetchTime: Date?
    private let cacheExpiryInterval: TimeInterval = 60 // 1 minute cache

    // MARK: - Initialization
    init(city: SearchResult, weatherService: WeatherServiceProtocol = WeatherServiceImpl()) {
        self.city = city
        self.weatherService = weatherService
        super.init(initialState: .initial)
    }

    // MARK: - Public Methods
    func fetchWeatherData() {
        guard let lat = city.latitude, let lng = city.longitude else { return }
        state = .loading
        let getWeatherQuery = WeatherRequestParameters(query: lat + "," + lng)
        weatherService.getWeather(query: getWeatherQuery)
            .receive(on: DispatchQueue.main)
            .sink(weak: self,
                  receiveValue: { [weak self] _, data in
                self?.weatherData = data
                self?.lastFetchTime = Date()
                self?.state = .success
            }, receiveCompletion: { viewModel, completion in
                if case .failure(let error) = completion {
                    viewModel.handleError(error)
                }
            })
            .store(in: &cancellables)
    }
}

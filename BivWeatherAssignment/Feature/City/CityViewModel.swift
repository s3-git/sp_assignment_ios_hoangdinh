import Combine
import Foundation
import SwiftUI

// MARK: - Weather Protocols
/// Location information protocol
protocol LocationInfoPresenter {
    var areaName: String { get }
    var regionName: String { get }
    var countryName: String { get }
    var localTime: String { get }
}

/// Current weather conditions protocol
protocol CurrentWeatherPresenter {
    var weatherDesc: String { get }
    var imageURL: String { get }
    var temperature: String { get }
    var feelsLike: String { get }
}

/// Atmospheric conditions protocol
protocol AtmosphericConditionsPresenter {
    var humidity: String { get }
    var pressure: String { get }
    var visibility: String { get }
    var cloudCover: String { get }
    var precipitation: String { get }
}

/// Wind information protocol
protocol WindInfoPresenter {
    var windSpeed: String { get }
    var windDirection: String { get }
}

/// Additional weather metrics protocol
protocol AdditionalWeatherInfoPresenter {
    var uvIndex: String { get }
    var observationTime: String { get }
}

/// Forecast protocol
protocol ForecastPresenter {
    var forecastDays: [ForecastDay] { get }
}

/// Combined weather presenter protocol
protocol WeatherPresenterProtocol: LocationInfoPresenter,
                                  CurrentWeatherPresenter,
                                  AtmosphericConditionsPresenter,
                                  WindInfoPresenter,
                                  AdditionalWeatherInfoPresenter,
                                  ForecastPresenter {}

// MARK: - Forecast Models
struct ForecastDay {
    let date: String
    let maxTemp: String
    let minTemp: String
    let avgTemp: String
    let sunHours: String
    let uvIndex: String
    let sunrise: String
    let sunset: String
    let moonrise: String
    let moonset: String
    let moonPhase: String
    let moonIllumination: String
    let hourlyForecasts: [HourlyForecast]
}

struct HourlyForecast {
    let time: String
    let temperature: String
    let weatherDesc: String
    let weatherIconURL: String
    let precipitation: String
    let humidity: String
    let cloudCover: String
    let windSpeed: String
    let windDirection: String
    let feelsLike: String
    let chanceOfRain: String
    let chanceOfSnow: String
    let visibility: String
    let uvIndex: String
}

// MARK: - WeatherData Extension
extension WeatherData: WeatherPresenterProtocol {
    // MARK: - Location Information
    var areaName: String {
        self.nearestArea?.first?.areaName?.first?.value ?? "Unknown Area"
    }

    var regionName: String {
        self.nearestArea?.first?.region?.first?.value ?? "Unknown Region"
    }

    var countryName: String {
        self.nearestArea?.first?.country?.first?.value ?? "Unknown Country"
    }

    var localTime: String {
        self.timeZone?.first?.localtime ?? "Unknown TimeZone"
    }

    // MARK: - Current Weather
    var weatherDesc: String {
        self.currentCondition?.first?.weatherDesc?.first?.value ?? "Unknown Weather"
    }

    var imageURL: String {
        self.currentCondition?.first?.weatherIconURL?.first?.value ?? ""
    }

    var temperature: String {
        "\(self.currentCondition?.first?.tempC ?? "Unknown")°C, \(self.currentCondition?.first?.tempF ?? "Unknown")°F"
    }

    var humidity: String {
        "\(self.currentCondition?.first?.humidity ?? "Unknown")%"
    }

    var feelsLike: String {
        "Feels like \(self.currentCondition?.first?.feelsLikeC ?? "Unknown")°C, \(self.currentCondition?.first?.feelsLikeF ?? "Unknown")°F"
    }

    var windSpeed: String {
        "\(self.currentCondition?.first?.windspeedKmph ?? "Unknown") km/h"
    }

    var windDirection: String {
        "\(self.currentCondition?.first?.winddir16Point ?? "Unknown") (\(self.currentCondition?.first?.winddirDegree ?? "Unknown")°)"
    }

    var pressure: String {
        "\(self.currentCondition?.first?.pressure ?? "Unknown") mb"
    }

    var visibility: String {
        "\(self.currentCondition?.first?.visibility ?? "Unknown") km"
    }

    var uvIndex: String {
        "UV Index: \(self.currentCondition?.first?.uvIndex ?? "Unknown")"
    }

    var precipitation: String {
        "\(self.currentCondition?.first?.precipMM ?? "Unknown") mm"
    }

    var cloudCover: String {
        "\(self.currentCondition?.first?.cloudcover ?? "Unknown")%"
    }

    // MARK: - Observation Details
    var observationTime: String {
        "Observed at: \(self.currentCondition?.first?.observationTime ?? "Unknown")"
    }

    // MARK: - 7-Day Forecast
    var forecastDays: [ForecastDay] {
        weather?.compactMap { day -> ForecastDay? in
            guard let astronomy = day.astronomy?.first else { return nil }

            let hourlyForecasts = (day.hourly ?? []).map { hourly -> HourlyForecast in
                // Convert 24-hour format to readable time (e.g., "0" -> "00:00", "1300" -> "13:00")
                let timeInt = Int(hourly.time ?? "0") ?? 0
                let hour = timeInt / 100
                let formattedTime = String(format: "%02d:00", hour)

                return HourlyForecast(
                    time: formattedTime,
                    temperature: "\(hourly.tempC ?? "Unknown")°C, \(hourly.tempF ?? "Unknown")°F",
                    weatherDesc: hourly.weatherDesc?.first?.value ?? "Unknown",
                    weatherIconURL: hourly.weatherIconURL?.first?.value ?? "",
                    precipitation: "\(hourly.precipMM ?? "Unknown") mm",
                    humidity: "\(hourly.humidity ?? "Unknown")%",
                    cloudCover: "\(hourly.cloudcover ?? "Unknown")%",
                    windSpeed: "\(hourly.windspeedKmph ?? "Unknown") km/h",
                    windDirection: "\(hourly.winddir16Point ?? "Unknown") (\(hourly.winddirDegree ?? "Unknown")°)",
                    feelsLike: "\(hourly.feelsLikeC ?? "Unknown")°C, \(hourly.feelsLikeF ?? "Unknown")°F",
                    chanceOfRain: "\(hourly.chanceofrain ?? "Unknown")%",
                    chanceOfSnow: "\(hourly.chanceofsnow ?? "Unknown")%",
                    visibility: "\(hourly.visibility ?? "Unknown") km",
                    uvIndex: hourly.uvIndex ?? "Unknown"
                )
            }

            return ForecastDay(
                date: day.date ?? "Unknown",
                maxTemp: "\(day.maxtempC ?? "Unknown")°C, \(day.maxtempF ?? "Unknown")°F",
                minTemp: "\(day.mintempC ?? "Unknown")°C, \(day.mintempF ?? "Unknown")°F",
                avgTemp: "\(day.avgtempC ?? "Unknown")°C, \(day.avgtempF ?? "Unknown")°F",
                sunHours: "\(day.sunHour ?? "Unknown") hours",
                uvIndex: "UV Index: \(day.uvIndex ?? "Unknown")",
                sunrise: astronomy.sunrise ?? "Unknown",
                sunset: astronomy.sunset ?? "Unknown",
                moonrise: astronomy.moonrise ?? "Unknown",
                moonset: astronomy.moonset ?? "Unknown",
                moonPhase: astronomy.moonPhase ?? "Unknown",
                moonIllumination: "\(astronomy.moonIllumination ?? "Unknown")%",
                hourlyForecasts: hourlyForecasts
            )
        } ?? []
    }
}

// MARK: - CityViewModel
/// ViewModel for managing city weather data
final class CityViewModel: BaseViewModel {
    // MARK: - Published Properties
    @Published var weatherData: (any WeatherPresenterProtocol)?

    // MARK: - Private Properties
    private let city: SearchResult
    private let weatherService: WeatherServiceProtocol
    private var lastFetchTime: Date?
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
        guard let lat = city.latitude, let lng = city.longitude else { return }
        state = .loading
        let getWeatherQuery = WeatherRequestParameters(query: lat + "," + lng)
        weatherService.getWeather(query: getWeatherQuery, forceRefresh: forceRefresh)
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

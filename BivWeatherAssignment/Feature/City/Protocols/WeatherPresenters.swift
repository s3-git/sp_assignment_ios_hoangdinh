import Foundation

// MARK: - Weather Protocols
public protocol LocationInfoPresenter {
    var areaName: String { get }
    var regionName: String { get }
    var countryName: String { get }
    var localTime: String { get }
}

public protocol CurrentWeatherPresenter {
    var weatherDesc: String { get }
    var imageURL: String { get }
    var temperature: String { get }
    var feelsLike: String { get }
}

public protocol AtmosphericConditionsPresenter {
    var humidity: String { get }
    var pressure: String { get }
    var visibility: String { get }
    var cloudCover: String { get }
    var precipitation: String { get }
}

public protocol WindInfoPresenter {
    var windSpeed: String { get }
    var windDirection: String { get }
}

public protocol AdditionalWeatherInfoPresenter {
    var uvIndex: String { get }
    var observationTime: String { get }
}

public protocol ForecastPresenter {
    var forecastDays: [ForecastDay] { get }
}

public protocol WeatherPresenterProtocol: LocationInfoPresenter,
                                        CurrentWeatherPresenter,
                                        AtmosphericConditionsPresenter,
                                        WindInfoPresenter,
                                        AdditionalWeatherInfoPresenter,
                                        ForecastPresenter {}

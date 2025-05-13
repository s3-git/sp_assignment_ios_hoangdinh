import Foundation

// MARK: - Weather Protocols
/// Location information protocol
public protocol LocationInfoPresenter {
    var areaName: String { get }
    var regionName: String { get }
    var countryName: String { get }
    var localTime: String { get }
}

/// Current weather conditions protocol
public protocol CurrentWeatherPresenter {
    var weatherDesc: String { get }
    var imageURL: String { get }
    var temperature: String { get }
    var feelsLike: String { get }
}

/// Atmospheric conditions protocol
public protocol AtmosphericConditionsPresenter {
    var humidity: String { get }
    var pressure: String { get }
    var visibility: String { get }
    var cloudCover: String { get }
    var precipitation: String { get }
}

/// Wind information protocol
public protocol WindInfoPresenter {
    var windSpeed: String { get }
    var windDirection: String { get }
}

/// Additional weather metrics protocol
public protocol AdditionalWeatherInfoPresenter {
    var uvIndex: String { get }
    var observationTime: String { get }
}

/// Forecast protocol
public protocol ForecastPresenter {
    var forecastDays: [ForecastDay] { get }
}

/// Combined weather presenter protocol
public protocol WeatherPresenterProtocol: LocationInfoPresenter,
                                        CurrentWeatherPresenter,
                                        AtmosphericConditionsPresenter,
                                        WindInfoPresenter,
                                        AdditionalWeatherInfoPresenter,
                                        ForecastPresenter {}

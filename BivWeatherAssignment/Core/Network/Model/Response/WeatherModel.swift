import Foundation

// MARK: - WeatherModel
struct WeatherModel: Codable {
    let data: WeatherData?
}

// MARK: - DataClass
struct WeatherData: Codable {
    let nearestArea: [NearestArea]?
    let timeZone: [TimeZone]?
    let currentCondition: [CurrentCondition]?

    enum CodingKeys: String, CodingKey {
        case nearestArea = "nearest_area"
        case timeZone = "time_zone"
        case currentCondition = "current_condition"
    }
}

// MARK: - CurrentCondition
struct CurrentCondition: Codable {
    let observationTime, tempC, tempF: String?
    let weatherIconURL, weatherDesc: [WeatherDesc]?
    let  windspeedKmph, winddirDegree, winddir16Point: String?
    let precipMM, humidity, visibility: String?
    let pressure, cloudcover: String?
    let feelsLikeC, feelsLikeF, uvIndex: String?

    enum CodingKeys: String, CodingKey {
        case observationTime = "observation_time"
        case tempC = "temp_C"
        case tempF = "temp_F"
        case weatherIconURL = "weatherIconUrl"
        case weatherDesc, windspeedKmph, winddirDegree, winddir16Point, precipMM, humidity, visibility, pressure, cloudcover
        case feelsLikeC = "FeelsLikeC"
        case feelsLikeF = "FeelsLikeF"
        case uvIndex
    }
}

// MARK: - WeatherDesc
struct WeatherDesc: Codable {
    let value: String?
}

// MARK: - NearestArea
struct NearestArea: Codable {
    let areaName, country, region: [WeatherDesc]?
}

// MARK: - TimeZone
struct TimeZone: Codable {
    let localtime: String?
}

// MARK: - WeatherData Extension

extension WeatherData {
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
    
}

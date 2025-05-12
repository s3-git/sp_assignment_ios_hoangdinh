import Foundation

// MARK: - City Search Response
struct CitySearchResponse: Codable {
    let searchAPI: SearchAPI
    
    enum CodingKeys: String, CodingKey {
        case searchAPI = "search_api"
    }
}

struct SearchAPI: Codable {
    let result: [CityResult]
}

struct CityResult: Codable {
    let areaName: [NameValue]
    let country: [NameValue]
    let region: [NameValue]
    let latitude: String
    let longitude: String
    let population: String
    let weatherUrl: [NameValue]
    
    enum CodingKeys: String, CodingKey {
        case areaName = "areaName"
        case country = "country"
        case region = "region"
        case latitude = "latitude"
        case longitude = "longitude"
        case population = "population"
        case weatherUrl = "weatherUrl"
    }
}

struct NameValue: Codable {
    let value: String
}

// MARK: - Weather Response
struct WeatherResponse: Codable {
    let data: WeatherData
}

struct WeatherData: Codable {
    let currentCondition: [CurrentCondition]
    
    enum CodingKeys: String, CodingKey {
        case currentCondition = "current_condition"
    }
}

struct CurrentCondition: Codable {
    let tempC: String
    let tempF: String
    let weatherCode: String
    let weatherIconUrl: [NameValue]
    let weatherDesc: [NameValue]
    let humidity: String
    let feelsLikeC: String
    let feelsLikeF: String
    
    enum CodingKeys: String, CodingKey {
        case tempC = "temp_C"
        case tempF = "temp_F"
        case weatherCode = "weatherCode"
        case weatherIconUrl = "weatherIconUrl"
        case weatherDesc = "weatherDesc"
        case humidity = "humidity"
        case feelsLikeC = "feelsLikeC"
        case feelsLikeF = "feelsLikeF"
    }
}

// MARK: - Domain Models
struct City: Identifiable {
    let id = UUID()
    let name: String
    let country: String
    let region: String
    let latitude: Double
    let longitude: Double
    let population: Int
    let weatherUrl: String
}

struct Weather {
    let temperature: Double
    let description: String
    let humidity: Int
    let iconUrl: URL?
    let feelsLike: Double
}

// MARK: - Mapping Extensions
extension CityResult {
    func toDomain() -> City {
        City(
            name: areaName.first?.value ?? "",
            country: country.first?.value ?? "",
            region: region.first?.value ?? "",
            latitude: Double(latitude) ?? 0.0,
            longitude: Double(longitude) ?? 0.0,
            population: Int(population) ?? 0,
            weatherUrl: weatherUrl.first?.value ?? ""
        )
    }
}

extension CurrentCondition {
    func toDomain() -> Weather {
        Weather(
            temperature: Double(tempC) ?? 0.0,
            description: weatherDesc.first?.value ?? "",
            humidity: Int(humidity) ?? 0,
            iconUrl: URL(string: weatherIconUrl.first?.value ?? ""),
            feelsLike: Double(feelsLikeC) ?? 0.0
        )
    }
} 
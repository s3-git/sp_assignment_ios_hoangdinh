import Foundation

/// Router for weather API endpoints
///
typealias Coordinates = (lat: String, lng: String)
enum WeatherRouter: Endpoint {
    case searchCity(query: WeatherSearchRequestParameters)
    case getWeather(query: WeatherRequestParameters)

    // MARK: - Endpoint Protocol
    var path: String {
        switch self {
        case .searchCity:
            return "/search.ashx"
        case .getWeather:
            return "/weather.ashx"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .searchCity, .getWeather:
            return .get
        }
    }

    var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }

    // MARK: - Query Parameters
    var queryItems: [URLQueryItem] {
        var items = [
            URLQueryItem(name: "key", value: Environment.shared.apiKey),
            URLQueryItem(name: "format", value: "json")
        ]

        switch self {
        case .searchCity(let query):
            items.append(contentsOf: query.toQueryItems())
        case .getWeather(let query):
            items.append(contentsOf: query.toQueryItems())
        }

        return items
    }

    // MARK: - Cache Configuration
    var cacheTime: TimeInterval {
        switch self {
        case .searchCity:
            return 3600 // 1 hour
        case .getWeather:
            return 60 // 1 minute
        }
    }

    // MARK: - URL Construction
    func asURL() -> URL? {
        var components = URLComponents(string: Environment.shared.baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
}

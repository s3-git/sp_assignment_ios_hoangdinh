import Foundation

/// Helper class for network testing
final class NetworkTestHelper {
    // MARK: - Properties
    static let shared = NetworkTestHelper()
    
    // MARK: - Mock Data
    func createMockWeatherResponse() -> Data {
        let json = """
        {
            "data": {
                "request": [{
                    "type": "City",
                    "query": "London"
                }],
                "nearest_area": [{
                    "areaName": [{"value": "London"}],
                    "country": [{"value": "UK"}],
                    "region": [{"value": "Greater London"}],
                    "latitude": "51.5074",
                    "longitude": "-0.1278",
                    "population": "8900000",
                    "weatherUrl": [{"value": "http://example.com/weather"}]
                }],
                "time_zone": [{
                    "localtime": "2024-03-12 12:00",
                    "utcOffset": "+0",
                    "zone": "Europe/London"
                }],
                "current_condition": [{
                    "observation_time": "2024-03-12 12:00",
                    "temp_C": "20",
                    "temp_F": "68",
                    "weatherCode": "113",
                    "weatherIconUrl": [{"value": "http://example.com/icon.png"}],
                    "weatherDesc": [{"value": "Sunny"}],
                    "windspeedMiles": "10",
                    "windspeedKmph": "16",
                    "winddirDegree": "180",
                    "winddir16Point": "S",
                    "precipMM": "0",
                    "precipInches": "0",
                    "humidity": "65",
                    "visibility": "10",
                    "visibilityMiles": "6",
                    "pressure": "1013",
                    "pressureInches": "30",
                    "cloudcover": "0",
                    "FeelsLikeC": "22",
                    "FeelsLikeF": "72",
                    "uvIndex": "6"
                }],
                "weather": [],
                "ClimateAverages": []
            }
        }
        """
        return json.data(using: .utf8)!
    }
    
    func createMockSearchResponse() -> Data {
        let json = """
        {
            "search_api": {
                "result": [{
                    "areaName": [{"value": "London"}],
                    "country": [{"value": "UK"}],
                    "region": [{"value": "Greater London"}],
                    "latitude": "51.5074",
                    "longitude": "-0.1278"
                }]
            }
        }
        """
        return json.data(using: .utf8)!
    }
    
    
    
    // MARK: - Helper Methods
    func createMockHTTPResponse(statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
    }
    
    func createMockError() -> Error {
        return NSError(
            domain: "com.example.error",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Mock network error"]
        )
    }
} 

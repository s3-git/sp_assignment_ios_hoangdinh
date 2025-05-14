@testable import BivWeatherAssignment
import XCTest

final class ModelTests: BaseXCTestCase {
    // MARK: - Properties
    private let networkHelper = NetworkTestHelper.shared
    
    // MARK: - WeatherData Tests
    func testWeatherDataDecoding() {
        // Given
        let mockData = networkHelper.createMockWeatherResponse()
        
        // When
        let weatherModel = try? JSONDecoder().decode(WeatherModel.self, from: mockData)
        
        // Then
        XCTAssertNotNil(weatherModel)
        XCTAssertNotNil(weatherModel?.data)
        XCTAssertEqual(weatherModel?.data?.request?.first?.query, "London")
        XCTAssertEqual(weatherModel?.data?.nearestArea?.first?.areaName?.first?.value, "London")
    }
    
    func testWeatherDataEncoding() {
        // Given
        let weatherData = WeatherData(
            request: [Request(type: "City", query: "London")],
            nearestArea: [
                NearestArea(
                    areaName: [WeatherDesc(value: "London")],
                    country: [WeatherDesc(value: "UK")],
                    region: [WeatherDesc(value: "Greater London")],
                    latitude: "51.5074",
                    longitude: "-0.1278",
                    population: "8900000",
                    weatherURL: [WeatherDesc(value: "http://example.com/weather")]
                )
            ],
            timeZone: [TimeZone(localtime: "2024-03-12 12:00", utcOffset: "+0", zone: "Europe/London")],
            currentCondition: [
                CurrentCondition(
                    observationTime: "2024-03-12 12:00",
                    tempC: "20",
                    tempF: "68",
                    weatherCode: "113",
                    weatherIconURL: [WeatherDesc(value: "http://example.com/icon.png")],
                    weatherDesc: [WeatherDesc(value: "Sunny")],
                    windspeedMiles: "10",
                    windspeedKmph: "16",
                    winddirDegree: "180",
                    winddir16Point: "S",
                    precipMM: "0",
                    precipInches: "0",
                    humidity: "65",
                    visibility: "10",
                    visibilityMiles: "6",
                    pressure: "1013",
                    pressureInches: "30",
                    cloudcover: "0",
                    feelsLikeC: "22",
                    feelsLikeF: "72",
                    uvIndex: "6"
                )
            ],
            weather: [],
            climateAverages: []
        )
        
        // When
        let encodedData = try? JSONEncoder().encode(weatherData)
        let decodedData = try? JSONDecoder().decode(WeatherData.self, from: encodedData!)
        
        // Then
        XCTAssertNotNil(encodedData)
        XCTAssertNotNil(decodedData)
        XCTAssertEqual(decodedData?.request?.first?.query, "London")
    }
    
    // MARK: - SearchResult Tests
    func testSearchResultDecoding() {
        // Given
        let mockData = networkHelper.createMockSearchResponse()
        
        // When
        let searchModel = try? JSONDecoder().decode(SearchModel.self, from: mockData)
        
        // Then
        XCTAssertNotNil(searchModel)
        XCTAssertNotNil(searchModel?.searchAPI?.result)
        XCTAssertEqual(searchModel?.searchAPI?.result?.first?.areaName?.first?.value, "London")
    }
    
    func testSearchResultEncoding() {
        // Given
        let searchResult = SearchResult(
            areaName: [AreaName(value: "London")],
            country: [AreaName(value: "UK")],
            region: [AreaName(value: "Greater London")],
            latitude: "51.5074",
            longitude: "-0.1278",
            population: "8900000",
            weatherURL: [AreaName(value: "http://example.com/weather")]
        )
        
        // When
        let encodedData = try? JSONEncoder().encode(searchResult)
        let decodedData = try? JSONDecoder().decode(SearchResult.self, from: encodedData!)
        
        // Then
        XCTAssertNotNil(encodedData)
        XCTAssertNotNil(decodedData)
        XCTAssertEqual(decodedData?.areaName?.first?.value, "London")
    }
    
    // MARK: - Request Parameters Tests
    func testWeatherSearchRequestParameters() {
        // Given
        let parameters = WeatherSearchRequestParameters(query: "London", numOfResults: 10)
        
        // When
        let queryItems = parameters.toQueryItems()
        
        // Then
        XCTAssertEqual(queryItems.count, 2)
        XCTAssertEqual(queryItems.first?.name, "q")
        XCTAssertEqual(queryItems.first?.value, "London")
        XCTAssertEqual(queryItems.last?.name, "num_of_results")
        XCTAssertEqual(queryItems.last?.value, "10")
    }
    
    // MARK: - Edge Cases Tests
    func testWeatherDataWithMissingFields() {
        // Given
        let jsonString = """
        {
            "data": {
                "request": [{"type": "City", "query": "London"}],
                "nearest_area": [],
                "current_condition": []
            }
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        // When
        let weatherModel = try? JSONDecoder().decode(WeatherModel.self, from: jsonData)
        
        // Then
        XCTAssertNotNil(weatherModel)
        XCTAssertNotNil(weatherModel?.data)
        XCTAssertNotNil(weatherModel?.data?.nearestArea)
        XCTAssertNotNil(weatherModel?.data?.currentCondition)
        XCTAssertTrue(weatherModel?.data?.nearestArea?.isEmpty ?? false)
        XCTAssertTrue(weatherModel?.data?.currentCondition?.isEmpty ?? false)
    }
    
    func testWeatherDataWithInvalidTemperature() {
        // Given
        let jsonString = """
        {
            "data": {
                "request": [{"type": "City", "query": "London"}],
                "current_condition": [{
                    "tempC": "invalid",
                    "tempF": "invalid",
                    "weatherCode": "113",
                    "weatherDesc": [{"value": "Sunny"}]
                }]
            }
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        // When
        let weatherModel = try? JSONDecoder().decode(WeatherModel.self, from: jsonData)
        
        // Then
        XCTAssertNotNil(weatherModel)
        XCTAssertNotNil(weatherModel?.data?.currentCondition?.first)
        XCTAssertNil(Int(weatherModel?.data?.currentCondition?.first?.tempC ?? ""))
        XCTAssertNil(Int(weatherModel?.data?.currentCondition?.first?.tempF ?? ""))
    }
    
    func testSearchResultWithEmptyArrays() {
        // Given
        let jsonString = """
        {
            "search_api": {
                "result": []
            }
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        // When
        let searchModel = try? JSONDecoder().decode(SearchModel.self, from: jsonData)
        
        // Then
        XCTAssertNotNil(searchModel)
        XCTAssertTrue(searchModel?.searchAPI?.result?.isEmpty ?? false)
    }
    
    func testWeatherDataWithSpecialCharacters() {
        // Given
        let weatherData = WeatherData(
            request: [Request(type: "City", query: "São Paulo")],
            nearestArea: [
                NearestArea(
                    areaName: [WeatherDesc(value: "São Paulo")],
                    country: [WeatherDesc(value: "Brasil")],
                    region: [WeatherDesc(value: "São Paulo")],
                    latitude: "-23.5505",
                    longitude: "-46.6333",
                    population: "12345678",
                    weatherURL: [WeatherDesc(value: "http://example.com/weather")]
                )
            ],
            timeZone: [],
            currentCondition: [],
            weather: [],
            climateAverages: []
        )
        
        // When
        let encodedData = try? JSONEncoder().encode(weatherData)
        let decodedData = try? JSONDecoder().decode(WeatherData.self, from: encodedData!)
        
        // Then
        XCTAssertNotNil(encodedData)
        XCTAssertNotNil(decodedData)
        XCTAssertEqual(decodedData?.request?.first?.query, "São Paulo")
        XCTAssertEqual(decodedData?.nearestArea?.first?.areaName?.first?.value, "São Paulo")
    }
} 

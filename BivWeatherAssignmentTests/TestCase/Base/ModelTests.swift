@testable import BivWeatherAssignment
import XCTest

final class ModelTests: BaseXCTestCase {
    
    // MARK: - WeatherModel Tests
    func testWeatherModelDecoding() {
        // Given
        let jsonString = """
        {
            "data": {
                "nearest_area": [{
                    "areaName": [{"value": "London"}],
                    "country": [{"value": "UK"}],
                    "region": [{"value": "Greater London"}]
                }],
                "time_zone": [{"localtime": "2024-05-15 12:00"}],
                "current_condition": [{
                    "observation_time": "12:00 PM",
                    "temp_C": "20",
                    "temp_F": "68",
                    "weatherIconUrl": [{"value": "http://example.com/icon.png"}],
                    "weatherDesc": [{"value": "Sunny"}],
                    "windspeedKmph": "10",
                    "winddirDegree": "180",
                    "winddir16Point": "S",
                    "precipMM": "0",
                    "humidity": "60",
                    "visibility": "10",
                    "pressure": "1013",
                    "cloudcover": "20",
                    "FeelsLikeC": "22",
                    "FeelsLikeF": "72",
                    "uvIndex": "5"
                }]
            }
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        // When
        let weatherModel = try? JSONDecoder().decode(WeatherModel.self, from: jsonData)
        
        // Then
        XCTAssertNotNil(weatherModel)
        XCTAssertNotNil(weatherModel?.data)
        XCTAssertEqual(weatherModel?.data?.areaName, "London")
        XCTAssertEqual(weatherModel?.data?.regionName, "Greater London")
        XCTAssertEqual(weatherModel?.data?.countryName, "UK")
        XCTAssertEqual(weatherModel?.data?.localTime, "2024-05-15 12:00")
        XCTAssertEqual(weatherModel?.data?.weatherDesc, "Sunny")
        XCTAssertEqual(weatherModel?.data?.imageURL, "http://example.com/icon.png")
        XCTAssertEqual(weatherModel?.data?.temperature, "20°C, 68°F")
        XCTAssertEqual(weatherModel?.data?.humidity, "60%")
        XCTAssertEqual(weatherModel?.data?.feelsLike, "Feels like 22°C, 72°F")
        XCTAssertEqual(weatherModel?.data?.windSpeed, "10 km/h")
        XCTAssertEqual(weatherModel?.data?.windDirection, "S (180°)")
        XCTAssertEqual(weatherModel?.data?.pressure, "1013 mb")
        XCTAssertEqual(weatherModel?.data?.visibility, "10 km")
        XCTAssertEqual(weatherModel?.data?.uvIndex, "UV Index: 5")
        XCTAssertEqual(weatherModel?.data?.precipitation, "0 mm")
        XCTAssertEqual(weatherModel?.data?.cloudCover, "20%")
        XCTAssertEqual(weatherModel?.data?.observationTime, "Observed at: 12:00 PM")
    }
    
    func testWeatherModelWithMissingData() {
        // Given
        let jsonString = """
        {
            "data": {
                "nearest_area": [],
                "time_zone": [],
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
        XCTAssertEqual(weatherModel?.data?.areaName, "Unknown Area")
        XCTAssertEqual(weatherModel?.data?.regionName, "Unknown Region")
        XCTAssertEqual(weatherModel?.data?.countryName, "Unknown Country")
        XCTAssertEqual(weatherModel?.data?.localTime, "Unknown TimeZone")
        XCTAssertEqual(weatherModel?.data?.weatherDesc, "Unknown Weather")
        XCTAssertEqual(weatherModel?.data?.imageURL, "")
        XCTAssertEqual(weatherModel?.data?.temperature, "Unknown°C, Unknown°F")
        XCTAssertEqual(weatherModel?.data?.humidity, "Unknown%")
        XCTAssertEqual(weatherModel?.data?.feelsLike, "Feels like Unknown°C, Unknown°F")
        XCTAssertEqual(weatherModel?.data?.windSpeed, "Unknown km/h")
        XCTAssertEqual(weatherModel?.data?.windDirection, "Unknown (Unknown°)")
        XCTAssertEqual(weatherModel?.data?.pressure, "Unknown mb")
        XCTAssertEqual(weatherModel?.data?.visibility, "Unknown km")
        XCTAssertEqual(weatherModel?.data?.uvIndex, "UV Index: Unknown")
        XCTAssertEqual(weatherModel?.data?.precipitation, "Unknown mm")
        XCTAssertEqual(weatherModel?.data?.cloudCover, "Unknown%")
        XCTAssertEqual(weatherModel?.data?.observationTime, "Observed at: Unknown")
    }
    
    // MARK: - WeatherData Tests
    func testWeatherDataDecoding() {
        // Given
        let mockData = networkHelper.createMockWeatherResponse()
        
        // When
        let weatherModel = try? JSONDecoder().decode(WeatherModel.self, from: mockData)
        
        // Then
        XCTAssertNotNil(weatherModel)
        XCTAssertNotNil(weatherModel?.data)
        XCTAssertEqual(weatherModel?.data?.nearestArea?.first?.areaName?.first?.value, "London")
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
    
    func testWeatherSearchRequestParametersWithoutNumOfResults() {
        // Given
        let parameters = WeatherSearchRequestParameters(query: "Paris", numOfResults: nil)
        
        // When
        let queryItems = parameters.toQueryItems()
        
        // Then
        XCTAssertEqual(queryItems.count, 1)
        XCTAssertEqual(queryItems.first?.name, "q")
        XCTAssertEqual(queryItems.first?.value, "Paris")
    }
    
    func testWeatherSearchRequestParametersWithSpecialCharacters() {
        // Given
        let queryName = "São Paulo, SP"
        let parameters = WeatherSearchRequestParameters(query: "São Paulo, SP", numOfResults: 5)
        
        // When
        let queryItems = parameters.toQueryItems()
        
        // Then
        XCTAssertEqual(queryItems.count, 2)
        XCTAssertEqual(queryItems.first?.name, "q")
        XCTAssertEqual(queryItems.first?.value, queryName)
        XCTAssertEqual(queryItems.last?.name, "num_of_results")
        XCTAssertEqual(queryItems.last?.value, "5")
    }
    
    func testWeatherSearchRequestParametersWithEmptyQuery() {
        // Given
        let parameters = WeatherSearchRequestParameters(query: "", numOfResults: 10)
        
        // When
        let queryItems = parameters.toQueryItems()
        
        // Then
        XCTAssertEqual(queryItems.count, 2)
        XCTAssertEqual(queryItems.first?.name, "q")
        XCTAssertEqual(queryItems.first?.value, "")
        XCTAssertEqual(queryItems.last?.name, "num_of_results")
        XCTAssertEqual(queryItems.last?.value, "10")
    }
    
    func testWeatherSearchRequestParametersWithCoordinates() {
        // Given
        let coordinates = "51.5074,-0.1278"
        let parameters = WeatherSearchRequestParameters(query: coordinates, numOfResults: nil)
        
        // When
        let queryItems = parameters.toQueryItems()
        
        // Then
        XCTAssertEqual(queryItems.count, 1)
        XCTAssertEqual(queryItems.first?.name, "q")
        XCTAssertEqual(queryItems.first?.value, coordinates)
    }
    
    func testWeatherSearchRequestParametersWithSpaces() {
        // Given
        let cityName = "New York City"
        let parameters = WeatherSearchRequestParameters(query: cityName, numOfResults: 3)
        
        // When
        let queryItems = parameters.toQueryItems()
        
        // Then
        XCTAssertEqual(queryItems.count, 2)
        XCTAssertEqual(queryItems.first?.name, "q")
        XCTAssertEqual(queryItems.first?.value, cityName)
        XCTAssertEqual(queryItems.last?.name, "num_of_results")
        XCTAssertEqual(queryItems.last?.value, "3")
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
//    
//    func testWeatherDataWithSpecialCharacters() {
//        // Given
//        let weatherData = WeatherData(
//            request: [Request(type: "City", query: "São Paulo")],
//            nearestArea: [
//                NearestArea(
//                    areaName: [WeatherDesc(value: "São Paulo")],
//                    country: [WeatherDesc(value: "Brasil")],
//                    region: [WeatherDesc(value: "São Paulo")],
//                    latitude: "-23.5505",
//                    longitude: "-46.6333",
//                    population: "12345678",
//                    weatherURL: [WeatherDesc(value: "http://example.com/weather")]
//                )
//            ],
//            timeZone: [],
//            currentCondition: [],
//            weather: [],
//            climateAverages: []
//        )
//        
//        // When
//        let encodedData = try? JSONEncoder().encode(weatherData)
//        let decodedData = try? JSONDecoder().decode(WeatherData.self, from: encodedData!)
//        
//        // Then
//        XCTAssertNotNil(encodedData)
//        XCTAssertNotNil(decodedData)
//        XCTAssertEqual(decodedData?.request?.first?.query, "São Paulo")
//        XCTAssertEqual(decodedData?.nearestArea?.first?.areaName?.first?.value, "São Paulo")
//    }

} 

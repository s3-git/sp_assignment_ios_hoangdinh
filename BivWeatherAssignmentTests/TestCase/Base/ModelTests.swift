@testable import BivWeatherAssignment
import XCTest

final class ModelTests: BaseXCTestCase {
    
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

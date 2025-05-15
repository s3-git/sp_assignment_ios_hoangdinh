@testable import BivWeatherAssignment
import XCTest

final class WeatherRequestParametersTests: XCTestCase {
    func testToQueryItems_WithAllParameters() {
        // Given
        let parameters = WeatherRequestParameters(
            query: "London",
            numOfDays: 3,
            date: "2024-05-12",
            fx: "yes",
            mca: "yes",
            fx24: "yes",
            tp: 6,
            showLocalTime: true,
            includeLocation: true
        )
        
        // When
        let queryItems = parameters.toQueryItems()
        
        // Then
        XCTAssertEqual(queryItems.count, 9)
        
        // Verify required parameters
        XCTAssertTrue(queryItems.contains { $0.name == "q" && $0.value == "London" })
        XCTAssertTrue(queryItems.contains { $0.name == "num_of_days" && $0.value == "3" })
        XCTAssertTrue(queryItems.contains { $0.name == "showlocaltime" && $0.value == "yes" })
        XCTAssertTrue(queryItems.contains { $0.name == "includelocation" && $0.value == "yes" })
        
        // Verify optional parameters
        XCTAssertTrue(queryItems.contains { $0.name == "date" && $0.value == "2024-05-12" })
        XCTAssertTrue(queryItems.contains { $0.name == "fx" && $0.value == "yes" })
        XCTAssertTrue(queryItems.contains { $0.name == "mca" && $0.value == "yes" })
        XCTAssertTrue(queryItems.contains { $0.name == "fx24" && $0.value == "yes" })
        XCTAssertTrue(queryItems.contains { $0.name == "tp" && $0.value == "6" })
    }
    
    func testToQueryItems_WithMinimalParameters() {
        // Given
        let parameters = WeatherRequestParameters(
            query: "London",
            numOfDays: 1,
            showLocalTime: true,
            includeLocation: true
        )
        
        // When
        let queryItems = parameters.toQueryItems()
        
        // Then
        XCTAssertEqual(queryItems.count, 4)
        
        // Verify required parameters
        XCTAssertTrue(queryItems.contains { $0.name == "q" && $0.value == "London" })
        XCTAssertTrue(queryItems.contains { $0.name == "num_of_days" && $0.value == "1" })
        XCTAssertTrue(queryItems.contains { $0.name == "showlocaltime" && $0.value == "yes" })
        XCTAssertTrue(queryItems.contains { $0.name == "includelocation" && $0.value == "yes" })
    }
    
    func testToQueryItems_WithEdgeCases() {
        // Given
        let parameters = WeatherRequestParameters(
            query: "New York, NY", // Special characters
            numOfDays: 0, // Edge case number
            date: "invalid-date", // Invalid date
            fx: "invalid", // Invalid fx value
            tp: 24, // Large time interval
            showLocalTime: false,
            includeLocation: false
        )
        
        // When
        let queryItems = parameters.toQueryItems()
        
        // Then
        XCTAssertEqual(queryItems.count, 7)
        XCTAssertTrue(queryItems.contains { $0.name == "q" && $0.value == "New York, NY" })
        XCTAssertTrue(queryItems.contains { $0.name == "num_of_days" && $0.value == "0" })
        XCTAssertTrue(queryItems.contains { $0.name == "date" && $0.value == "invalid-date" })
        XCTAssertTrue(queryItems.contains { $0.name == "fx" && $0.value == "invalid" })
        XCTAssertTrue(queryItems.contains { $0.name == "tp" && $0.value == "24" })
        XCTAssertTrue(queryItems.contains { $0.name == "showlocaltime" && $0.value == "no" })
        XCTAssertTrue(queryItems.contains { $0.name == "includelocation" && $0.value == "no" })
    }
} 

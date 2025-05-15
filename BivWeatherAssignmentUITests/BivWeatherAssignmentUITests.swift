////
////  BivWeatherAssignmentUITests.swift
////  BivWeatherAssignmentUITests
////
////  Created by hoang.dinh on 5/9/25.
////
//

import XCTest

final class BivWeatherAssignmentUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testBasicNavigation() throws {
        // Test search functionality
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.exists, "Search field should exist")
        
        // Test search interaction
        searchField.tap()
        searchField.typeText("London")
        
        // Wait for search results
        let searchResults = app.tables.firstMatch
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: searchResults)
        waitForExpectations(timeout: 5)
        
        // Verify search results
        XCTAssertTrue(searchResults.exists, "Search results should be displayed")
    }
    
}

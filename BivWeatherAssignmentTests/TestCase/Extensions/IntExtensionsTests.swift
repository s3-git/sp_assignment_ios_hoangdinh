//
//  IntExtensionsTests.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/15/25.
//
@testable import BivWeatherAssignment
import XCTest

final class IntExtensionsTests: BaseXCTestCase {
    
    // MARK: - Int+Extensions Tests
    func testFormatPopulationWithBillion() {
        // Given
        let population = 2_500_000_000.0
        
        // When
        let formatted = population.formatPopulation()
        
        // Then
        XCTAssertEqual(formatted, "2.5B")
    }
    
    func testFormatPopulationWithMillion() {
        // Given
        let population = 2_500_000.0
        
        // When
        let formatted = population.formatPopulation()
        
        // Then
        XCTAssertEqual(formatted, "2.5M")
    }
    
    func testFormatPopulationWithThousand() {
        // Given
        let population = 2_500.0
        
        // When
        let formatted = population.formatPopulation()
        
        // Then
        XCTAssertEqual(formatted, "2.5K")
    }
    
    func testFormatPopulationWithLessThanThousand() {
        // Given
        let population = 500.0
        
        // When
        let formatted = population.formatPopulation()
        
        // Then
        XCTAssertEqual(formatted, "500.0")
    }
    
    func testFormatPopulationWithZero() {
        // Given
        let population = 0.0
        
        // When
        let formatted = population.formatPopulation()
        
        // Then
        XCTAssertEqual(formatted, "0.0")
    }
}

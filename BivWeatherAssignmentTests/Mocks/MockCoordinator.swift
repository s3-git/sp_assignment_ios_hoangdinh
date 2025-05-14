import Foundation
import UIKit

/// Mock implementation of Coordinator for testing
final class MockCoordinator: Coordinator, MockProtocol {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController, showCityDetailCalled: Bool = false, lastCity: SearchResult? = nil) {
        self.navigationController = navigationController
        self.showCityDetailCalled = showCityDetailCalled
        self.lastCity = lastCity
    }
    func start() {
        showCityDetailCalled = false
        lastCity = nil
    }
    
    // MARK: - Properties
    var showCityDetailCalled = false
    var lastCity: SearchResult?
    
    // MARK: - Coordinator
    func showCityDetail(for city: SearchResult) {
        showCityDetailCalled = true
        lastCity = city
    }
    
    // MARK: - MockProtocol
    func reset() {
        showCityDetailCalled = false
        lastCity = nil
    }
} 

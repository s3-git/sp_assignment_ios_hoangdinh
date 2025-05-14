import Foundation
import UIKit

/// Mock implementation of Coordinator for testing
final class MockCoordinator: Coordinator, MockProtocol {
    let navigationController: UINavigationController
    
    
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    func start() {
    }
    
    
    // MARK: - Properties
    var showCityDetailCalled:Bool?

    // MARK: - Coordinator
    func showCityDetail(for city: SearchResult) {
        showCityDetailCalled = true
    }
    
    // MARK: - MockProtocol
    func reset() {
        showCityDetailCalled = false
    }
} 

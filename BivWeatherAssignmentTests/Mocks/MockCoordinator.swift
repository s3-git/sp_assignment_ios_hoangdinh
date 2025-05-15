import Foundation
import SwiftUI
import UIKit

final class MockCoordinator: Coordinator, MockProtocol {
    // MARK: - Properties
    let navigationController: UINavigationController
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Coordinator Methods
    func start() {
        showHomeAsRoot()
    }
    
    func showHomeAsRoot() {
        let mockHomeVC = UIViewController()
        mockHomeVC.title = "Home"
        navigationController.setViewControllers([mockHomeVC], animated: false)
    }
    
    func showCityDetail(for city: SearchResult) {
        let mockDetailVC = UIViewController()
        mockDetailVC.title = city.areaName?.first?.value
        navigationController.pushViewController(mockDetailVC, animated: false)
    }
    
    // MARK: - MockProtocol
    func reset() {
        navigationController.setViewControllers([], animated: false)
    }
} 

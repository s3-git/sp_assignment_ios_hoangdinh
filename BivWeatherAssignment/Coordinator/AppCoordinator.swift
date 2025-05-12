import UIKit
import SwiftUI

/// Protocol defining coordinator capabilities
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
    func showCityDetail(for city: SearchResult)
}

/// Main app coordinator
final class AppCoordinator: Coordinator {
    // MARK: - Properties
    let navigationController: UINavigationController
    private let weatherService: WeatherServiceProtocol

    // MARK: - Initialization
    init(navigationController: UINavigationController, weatherService: WeatherServiceProtocol = WeatherServiceImpl()) {
        self.navigationController = navigationController
        self.weatherService = weatherService
    }

    // MARK: - Coordinator Methods
    func start() {
        showHome()
    }

    func showHome() {
        let viewModel = HomeViewModel(weatherService: weatherService)
        viewModel.coordinator = self // Set coordinator before creating view controller
        let viewController = HomeViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    func showCityDetail(for city: SearchResult) {
        let cityViewModel = CityViewModel(city: city, weatherService: weatherService)
        let cityView = CityView(viewModel: cityViewModel)
        let hostingController = UIHostingController(rootView: cityView)
        navigationController.pushViewController(hostingController, animated: true)
    }
}

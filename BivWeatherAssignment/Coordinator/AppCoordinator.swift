import SwiftUI
import UIKit

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
    private let recentCityService: RecentCitiesServiceProtocol

    // MARK: - Initialization
    init(navigationController: UINavigationController, weatherService: WeatherServiceProtocol = WeatherServiceImpl(),recentCityService: RecentCitiesServiceProtocol = RecentCitiesServiceImpl()) {
        self.navigationController = navigationController
        self.weatherService = weatherService
        self.recentCityService = recentCityService
    }

    // MARK: - Coordinator Methods
    func start() {
        showHomeAsRoot()
    }

    func showHomeAsRoot() {
        let viewModel = HomeViewModel(weatherService: weatherService,recentCitiesService: recentCityService, coordinator: self)
        let viewController = HomeViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    func showCityDetail(for city: SearchResult) {
        let navBarHeight = navigationController.navigationBar.frame.height
        let cityViewModel = CityViewModel(city: city, navBarHeight: navBarHeight, weatherService: weatherService)
        let cityView = CityView(viewModel: cityViewModel)
        let hostingController = UIHostingController(rootView: cityView)
        navigationController.pushViewController(hostingController, animated: true)
    }
}

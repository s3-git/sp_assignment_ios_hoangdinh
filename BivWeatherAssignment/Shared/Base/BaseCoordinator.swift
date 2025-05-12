import SwiftUI
import Combine

/// Base coordinator protocol for handling navigation
protocol BaseCoordinator: AnyObject {
    var navigationPath: NavigationPath { get set }
    var cancellables: Set<AnyCancellable> { get set }
    
    func start()
    func navigate(to destination: any Hashable)
    func navigateBack()
    func navigateToRoot()
}

/// Default implementation of BaseCoordinator
class DefaultCoordinator: BaseCoordinator {
    // MARK: - Properties
    @Published var navigationPath = NavigationPath()
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Override in subclasses
    }
    
    // MARK: - Public Methods
    func start() {
        // Override in subclasses
    }
    
    func navigate(to destination: any Hashable) {
        navigationPath.append(destination)
    }
    
    func navigateBack() {
        navigationPath.removeLast()
    }
    
    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    // MARK: - Deinitialization
    deinit {
        cancellables.removeAll()
    }
} 

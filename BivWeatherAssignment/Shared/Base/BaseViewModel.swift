import Foundation
import Combine

/// Base protocol for all ViewModels in the application
protocol BaseViewModelType: AnyObject {

    /// The current state of the ViewModel
    var state: ViewState { get }

    /// Publisher for state changes
    var statePublisher: AnyPublisher<ViewState, Never> { get }

    /// Set of cancellables for managing subscriptions
    var cancellables: Set<AnyCancellable> { get set }

    /// Setup bindings for the view model
    func setupBindings()

    /// Handle errors in a consistent way
    func handleError(_ error: Error)
}

/// Base view model that provides common functionality for all view models
class BaseViewModel: ObservableObject, BaseViewModelType {
    // MARK: - Published Properties
    @Published var state: ViewState

    // MARK: - Properties
    var statePublisher: AnyPublisher<ViewState, Never> {
        $state.eraseToAnyPublisher()
    }

    var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(initialState: ViewState) {
        self.state = initialState
        setupBindings()
    }

    // MARK: - Public Methods
    /// Setup bindings for the view model
    func setupBindings() {
        // Override in subclasses
    }

    /// Handle errors in a consistent way
    func handleError(_ error: Error) {
        self.state = .error(error.localizedDescription)
        Logger.shared.error(error.localizedDescription)
    }

    /// Store cancellable
    func store(_ cancellable: AnyCancellable) {
        cancellable.store(in: &cancellables)
    }

    /// Cancel all subscriptions
    func cancelAllSubscriptions() {
        cancellables.removeAll()
    }

    // MARK: - Deinitialization
    deinit {
        cancelAllSubscriptions()
    }
}

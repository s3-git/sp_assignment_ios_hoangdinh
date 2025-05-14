import Combine
import Foundation

/// Base protocol for all ViewModels in the application
protocol BaseViewModelType: AnyObject {

    /// The current state of the ViewModel
    var state: ViewState { get }

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

    var cancellables = Set<AnyCancellable>()

    // MARK: - Dependencies
    private let errorHandler: ErrorHandlingServiceProtocol

    // MARK: - Initialization
    init(initialState: ViewState = .initial,
         errorHandler: ErrorHandlingServiceProtocol = ErrorHandlingService()) {
        self.state = initialState
        self.errorHandler = errorHandler
        setupBindings()
    }

    // MARK: - Public Methods
    /// Setup bindings for the view model
    func setupBindings() {
        // Override in subclasses
    }

    /// Handle errors in a consistent way
    func handleError(_ error: Error) {
        let errorMessage = errorHandler.handle(error)

        // Update state with error and recovery suggestion
        self.state = .error(errorMessage)

        // Log error
        errorHandler.logError(error)

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

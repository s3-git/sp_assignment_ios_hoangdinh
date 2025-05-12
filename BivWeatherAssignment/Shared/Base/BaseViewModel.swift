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
        let recoverySuggestion = errorHandler.getRecoverySuggestion(for: error)

        // Update state with error and recovery suggestion
        if let suggestion = recoverySuggestion {
            self.state = .error("\(errorMessage)\n\n\(suggestion)")
        } else {
            self.state = .error(errorMessage)
        }

        // Log error
        errorHandler.logError(error)

        // If error is recoverable, attempt recovery after delay
        if errorHandler.isRecoverable(error) {
            attemptRecovery(from: error)
        }
    }

    /// Store cancellable
    func store(_ cancellable: AnyCancellable) {
        cancellable.store(in: &cancellables)
    }

    /// Cancel all subscriptions
    func cancelAllSubscriptions() {
        cancellables.removeAll()
    }

    // MARK: - Private Methods
    private func attemptRecovery(from error: Error) {
        // Wait for 3 seconds before attempting recovery
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }

            // Only attempt recovery if still in error state
            if case .error = self.state {
                self.state = .initial
                self.retryLastOperation()
            }
        }
    }

    /// Override this method in subclasses to implement retry logic
    func retryLastOperation() {
        // Default implementation does nothing
        // Override in subclasses to implement specific retry logic
    }

    // MARK: - Deinitialization
    deinit {
        cancelAllSubscriptions()
    }
}

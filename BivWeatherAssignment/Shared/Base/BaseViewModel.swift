import Foundation
import Combine

/// Base protocol for all ViewModels in the application
protocol BaseViewModelType: AnyObject {
    associatedtype State
    
    /// The current state of the ViewModel
    var state: State { get }
    
    /// Publisher for state changes
    var statePublisher: AnyPublisher<State, Never> { get }
    
    /// Set of cancellables for managing subscriptions
    var cancellables: Set<AnyCancellable> { get set }
    
    /// Setup bindings for the view model
    func setupBindings()
    
    /// Handle errors in a consistent way
    func handleError(_ error: Error)
}

/// Base view model that provides common functionality for all view models
class BaseViewModel<State>: ObservableObject, BaseViewModelType {
    // MARK: - Published Properties
    @Published var state: State
    @Published var isLoading = false
    @Published var error: Error?
    
    // MARK: - Properties
    var statePublisher: AnyPublisher<State, Never> {
        $state.eraseToAnyPublisher()
    }
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(initialState: State) {
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
        self.error = error
        self.isLoading = false
        Logger.shared.error(error.localizedDescription)
    }
    
    /// Reset error state
    func resetError() {
        self.error = nil
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

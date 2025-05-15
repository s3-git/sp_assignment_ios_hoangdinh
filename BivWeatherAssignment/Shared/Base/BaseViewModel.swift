import Combine
import Foundation

protocol BaseViewModelType: AnyObject {
    
    var state: ViewState { get }
    
    var cancellables: Set<AnyCancellable> { get set }
    
    func setupBindings()
    
    func handleError(_ error: NetworkError)
}

class BaseViewModel: ObservableObject, BaseViewModelType {
    // MARK: - Published Properties
    @Published var state: ViewState
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(initialState: ViewState = .initial) {
        self.state = initialState
        setupBindings()
    }
    
    // MARK: - Public Methods
    func setupBindings() {
        // Override in subclasses
    }
    
    func handleError(_ error: NetworkError) {
        
        // Update state with error and recovery suggestion
        self.state = .error(error.localizedDescription)
        
    }
    
    func cancelAllSubscriptions() {
        cancellables.removeAll()
    }
    
    // MARK: - Deinitialization
    deinit {
        cancelAllSubscriptions()
    }
}

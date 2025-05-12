import UIKit



/// Base view that provides common functionality for all UIKit views
class BaseUIView: UIView {
    // MARK: - Properties
    private var viewState: ViewState = .success {
        didSet {
            updateViewState()
        }
    }
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No data available"
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        addSubview(loadingIndicator)
        addSubview(errorLabel)
        addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        updateViewState()
    }
    
    private func updateViewState() {
        loadingIndicator.stopAnimating()
        errorLabel.isHidden = true
        emptyLabel.isHidden = true
        
        switch viewState {
        case .loading:
            loadingIndicator.startAnimating()
        case .error(let message):
            errorLabel.text = message
            errorLabel.isHidden = false
            // Auto-dismiss error after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.showSuccess()
            }
        case .empty:
            emptyLabel.isHidden = false
        case .success:
            break
        }
    }
    
    // MARK: - Public Methods
    /// Show loading state
    func showLoading() {
        viewState = .loading
    }
    
    /// Show error state
    func showError(_ error: Error) {
        viewState = .error(error.localizedDescription)
    }
    
    /// Show empty state
    func showEmpty() {
        viewState = .empty
    }
    
    /// Show success state
    func showSuccess() {
        viewState = .success
    }
} 

import UIKit

/// Base view that provides common functionality for all UIKit views
class BaseViewController: UIViewController {
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
        indicator.accessibilityIdentifier = "loadingIndicator"

        return indicator
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "errorLabel"
        return label
    }()

    override func viewDidLoad() {
        setupUI()
    }
    // MARK: - Private Methods
    private func setupUI() {

        view.addSubview(loadingIndicator)
        view.addSubview(errorLabel)

        NSLayoutConstraint.activate([

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)

        ])

        // Ensure loadingIndicator and emptyLabel always overlay on top

        updateViewState()
    }

    private func updateViewState() {
        loadingIndicator.stopAnimating()
        errorLabel.isHidden = true

        switch viewState {
            case .loading:
                loadingIndicator.startAnimating()
                view.bringSubviewToFront(loadingIndicator)

            case .error(let message):
                errorLabel.text = message
                errorLabel.isHidden = false
                // Auto-dismiss error after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    self?.handleState(state: .success)
                }

            default:
                break
        }
    }

    // MARK: - Public Methods
    /// Show loading state
    func handleState(state: ViewState) {
        viewState = state
    }

}

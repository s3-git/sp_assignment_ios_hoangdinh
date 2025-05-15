import UIKit

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
    
    private lazy var backgroundImage: UIImageView = {
        let uiImageView = UIImageView(image: UIImage(named: AppConstants.Assets.imgBackground))
        uiImageView.translatesAutoresizingMaskIntoConstraints = false
        uiImageView.accessibilityIdentifier = "backgroundImage"
        return uiImageView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.addSubview(loadingIndicator)
        view.addSubview(backgroundImage)
        
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.sendSubviewToBack(backgroundImage)
        updateViewState()
    }

    private func updateViewState() {
        cleanup()

        switch viewState {
        case .loading:
            loadingIndicator.startAnimating()
            view.bringSubviewToFront(loadingIndicator)

        case .error(let message):
            // Ensure toast is shown on main thread
            DispatchQueue.main.async { [weak self] in
                Toast.show(message: message)
                // Auto-dismiss error after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    self?.handleState(state: .success)
                }
            }
            
        default:
            cleanup()
        }
    }
    
    private func cleanup() {
        loadingIndicator.stopAnimating()
    }

    // MARK: - Public Methods
    func handleState(state: ViewState) {
        viewState = state
    }
}

import Combine
import UIKit

/// Home screen view controller
final class HomeViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    private let keyboardManager = KeyboardManager.shared

    // MARK: - UI Components
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.accessibilityIdentifier = "searchBar"
        searchBar.searchTextField.font = ThemeManager.Fonts.caption
        searchBar.placeholder = "Search cities..."

        // Make search bar transparent and more beautiful
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        searchBar.searchTextField.backgroundColor = ThemeManager.shared.textColor.withAlphaComponent(0.1)
        searchBar.searchTextField.layer.cornerRadius = 10
        searchBar.searchTextField.clipsToBounds = true

        // Update search icon color
        if let searchIconView = searchBar.searchTextField.leftView as? UIImageView {
            searchIconView.tintColor = ThemeManager.shared.textColor.withAlphaComponent(0.6)
        }

        // Add padding to search text field
        searchBar.searchTextField.leftView?.tintColor = ThemeManager.shared.textColor.withAlphaComponent(0.6)
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 8, vertical: 0)

        return searchBar
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CityCell.self, forCellReuseIdentifier: CityCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.accessibilityIdentifier = "tableView"
        tableView.keyboardDismissMode = .onDrag
        // Add content inset to prevent content from being hidden under keyboard
        tableView.contentInsetAdjustmentBehavior = .automatic
        return tableView
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No cities viewed yet"
        label.textAlignment = .center
        label.font = ThemeManager.Fonts.body
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "emptyLabel"
        return label
    }()

    private lazy var emptyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "emptyView"
        view.addSubview(emptyLabel)
        return view
    }()

    // MARK: - Initialization
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
        setupBindings()
        initData()
        applyTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
    }

    // MARK: - Private Methods
    private func setupUI() {
        title = "Weather"
        
        // Add clear all button
        let clearButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(clearAllRecentCities)
        )
        clearButton.accessibilityIdentifier = "clearAllButton"
        navigationItem.rightBarButtonItem = clearButton

        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(emptyView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor)
        ])

        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func setupKeyboardHandling() {
        keyboardManager.$keyboardHeight
            .receive(on: DispatchQueue.main)
            .sink { [weak self] height in
                self?.adjustContentForKeyboard(height: height)
            }
            .store(in: &cancellables)
    }

    private func adjustContentForKeyboard(height: CGFloat) {
        let bottomInset = height > 0 ? height - view.safeAreaInsets.bottom : 0
        tableView.contentInset.bottom = bottomInset
        tableView.verticalScrollIndicatorInsets.bottom = bottomInset

        // If search bar is active and content would be hidden, scroll to top
        if searchBar.isFirstResponder && height > 0 {
            tableView.setContentOffset(.zero, animated: true)
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupBindings() {
        // Bind cities
        viewModel.$cities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateTableViewState()
            }
            .store(in: &cancellables)

        // Bind recent cities
        viewModel.$recentCities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateTableViewState()
            }
            .store(in: &cancellables)

        // Bind showing recent cities
        viewModel.$showingRecentCities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showingRecent in
                self?.updateTableViewState()
                self?.updateClearButtonVisibility(showingRecent)
            }
            .store(in: &cancellables)

        // Bind view model state
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleState(state: state)
            }
            .store(in: &cancellables)
    }

    private func updateClearButtonVisibility(_ showingRecent: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = showingRecent
        navigationItem.rightBarButtonItem?.tintColor = showingRecent ? 
            ThemeManager.shared.textColor : 
            ThemeManager.shared.textColor.withAlphaComponent(0.3)
    }

    private func updateTableViewState() {
        let hasData = viewModel.showingRecentCities ? !viewModel.recentCities.isEmpty : !viewModel.cities.isEmpty
        emptyView.isHidden = hasData
        tableView.reloadData()
    }

    private func applyTheme() {
        emptyView.backgroundColor = ThemeManager.shared.backgroundColor
        view.backgroundColor = ThemeManager.shared.backgroundColor
        searchBar.barTintColor = .clear
        searchBar.backgroundColor = .clear
        searchBar.searchTextField.backgroundColor = ThemeManager.shared.textColor.withAlphaComponent(0.1)
        searchBar.tintColor = ThemeManager.shared.textColor
        searchBar.searchTextField.textColor = ThemeManager.shared.textColor

        // Update search icon color when theme changes
        if let searchIconView = searchBar.searchTextField.leftView as? UIImageView {
            searchIconView.tintColor = ThemeManager.shared.textColor.withAlphaComponent(0.6)
        }

        // Update placeholder color
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search cities...",
            attributes: [
                .foregroundColor: ThemeManager.shared.textColor.withAlphaComponent(0.6),
                .font: ThemeManager.Fonts.caption
            ]
        )

        tableView.backgroundColor = ThemeManager.shared.backgroundColor
        emptyLabel.textColor = ThemeManager.shared.textColor
        tableView.reloadData()
    }

    private func initData() {
        self.handleState(state: .loading)
    }

    // MARK: - Actions
    @objc private func clearAllRecentCities() {
        let alert = UIAlertController(
            title: "Clear Recent Cities",
            message: "Are you sure you want to clear all recent cities?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            self?.viewModel.clearAllRecentCities()
        })
        
        present(alert, animated: true)
    }

    private func removeCity(at indexPath: IndexPath) {
        // Safety check for index
        guard indexPath.row < viewModel.recentCities.count else {
            return
        }
        
        let city = viewModel.recentCities[indexPath.row]
        
        // Animate the removal
        tableView.beginUpdates()
        viewModel.removeRecentCity(city)
        
        // Safety check for index after removal
        if indexPath.row < tableView.numberOfRows(inSection: indexPath.section) {
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else {
            tableView.reloadData()
        }
        
        tableView.endUpdates()
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.showingRecentCities ? viewModel.recentCities.count : viewModel.cities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CityCell.identifier, for: indexPath) as? CityCell else {
            return UITableViewCell()
        }

        // Safety check for index
        guard indexPath.row < (viewModel.showingRecentCities ? viewModel.recentCities.count : viewModel.cities.count) else {
            return cell
        }

        let city = viewModel.showingRecentCities ? viewModel.recentCities[indexPath.row] : viewModel.cities[indexPath.row]
        
        // Configure cell with recent city state
        cell.configure(
            with: city,
            onRemove: viewModel.showingRecentCities ? { [weak self] in
                self?.removeCity(at: indexPath)
            } : nil,
            isRecentCity: viewModel.showingRecentCities
        )
        
        cell.backgroundColor = ThemeManager.shared.backgroundColor
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.showingRecentCities ? "Recent Cities" : "Search Results"
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Safety check for index
        guard indexPath.row < (viewModel.showingRecentCities ? viewModel.recentCities.count : viewModel.cities.count) else {
            return
        }
        
        let city = viewModel.showingRecentCities ? viewModel.recentCities[indexPath.row] : viewModel.cities[indexPath.row]
        viewModel.didSelectCity(city)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120 // Estimated height for better performance
    }
}

// MARK: - UISearchBarDelegate
extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBar.setShowsCancelButton(true, animated: true)
//    }
//
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        searchBar.setShowsCancelButton(false, animated: true)
//    }
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.text = ""
//        searchBar.resignFirstResponder()
//        viewModel.searchText = ""
//    }
}

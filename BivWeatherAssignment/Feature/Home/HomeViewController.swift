import UIKit
import Combine

/// Home screen view controller
final class HomeViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search cities..."
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.accessibilityIdentifier = "searchBar"
        return searchBar
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CityCell.self, forCellReuseIdentifier: CityCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.accessibilityIdentifier = "tableView"
        return tableView
    }()
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No data available"
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "emptyLabel"
        return label
    }()

    private lazy var emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
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
        setupBindings()
        initData()
        for view in self.view.subviews {
            print("\(view.accessibilityIdentifier) : \(view.isHidden)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
    }

    // MARK: - Private Methods
    private func setupUI() {
        title = "Weather"
        view.backgroundColor = ThemeManager.shared.backgroundColor
        // Add subviews
        emptyView.isHidden = true
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(emptyView)
        // Setup constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppConstants.UserInterface.padding),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppConstants.UserInterface.padding),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppConstants.UserInterface.padding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppConstants.UserInterface.padding),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppConstants.UserInterface.padding),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppConstants.UserInterface.padding),
            emptyView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor)
        ])
    }
    private func showEmpty(_ show: Bool) {
    }
    private func setupBindings() {
        // Bind view model states
        viewModel.$cities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] city in
                self?.emptyView.isHidden = !city.isEmpty
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleState(state: state)
            }
            .store(in: &cancellables)
    }

    private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        searchBar.barTintColor = ThemeManager.shared.backgroundColor
        searchBar.tintColor = ThemeManager.shared.accent
        tableView.backgroundColor = ThemeManager.shared.backgroundColor
        tableView.reloadData()
    }

    // MARK: - Request
    private func initData() {
        self.handleState(state: .loading)
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CityCell.identifier, for: indexPath) as? CityCell else {
            return UITableViewCell()
        }

        let city = viewModel.cities[indexPath.row]
        cell.configure(with: city)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let city = viewModel.cities[indexPath.row]
        viewModel.didSelectCity(city)
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
}

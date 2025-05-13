import UIKit

/// Cell for displaying city information with enhanced layout
final class CityCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "CityCell"

    var onRemove: (() -> Void)?
    private var isRecentCity: Bool = false

    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.backgroundColor.withAlphaComponent(0.6)
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeManager.Fonts.headline
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var regionLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeManager.Fonts.body
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var countryLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeManager.Fonts.caption
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var locationIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
        imageView.tintColor = ThemeManager.shared.textColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var latLongLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeManager.Fonts.caption
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var populationIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.3.fill"))
        imageView.tintColor = ThemeManager.shared.textColor.withAlphaComponent(0.8)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var populationLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeManager.Fonts.caption
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = ThemeManager.shared.textColor.withAlphaComponent(0.6)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "removeCityButton"
        button.isUserInteractionEnabled = false
        return button
    }()

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear

        // Add subviews
        contentView.addSubview(containerView)
        containerView.addSubview(locationIcon)
        containerView.addSubview(cityLabel)
        containerView.addSubview(regionLabel)
        containerView.addSubview(countryLabel)
        containerView.addSubview(latLongLabel)
        containerView.addSubview(populationIcon)
        containerView.addSubview(populationLabel)
        containerView.addSubview(removeButton)

        // Setup constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ThemeManager.Spacing.small),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ThemeManager.Spacing.medium),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ThemeManager.Spacing.medium),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ThemeManager.Spacing.small),

            locationIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ThemeManager.Spacing.medium),
            locationIcon.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ThemeManager.Spacing.medium),
            locationIcon.widthAnchor.constraint(equalToConstant: 24),
            locationIcon.heightAnchor.constraint(equalToConstant: 24),

            cityLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ThemeManager.Spacing.medium),
            cityLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: ThemeManager.Spacing.medium),
            cityLabel.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -ThemeManager.Spacing.medium),

            regionLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: ThemeManager.Spacing.small),
            regionLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: ThemeManager.Spacing.medium),
            regionLabel.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -ThemeManager.Spacing.medium),

            countryLabel.topAnchor.constraint(equalTo: regionLabel.bottomAnchor, constant: ThemeManager.Spacing.small),
            countryLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: ThemeManager.Spacing.medium),
            countryLabel.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -ThemeManager.Spacing.medium),

            latLongLabel.topAnchor.constraint(equalTo: countryLabel.bottomAnchor, constant: ThemeManager.Spacing.small),
            latLongLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: ThemeManager.Spacing.medium),
            latLongLabel.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -ThemeManager.Spacing.medium),

            populationIcon.topAnchor.constraint(equalTo: latLongLabel.bottomAnchor, constant: ThemeManager.Spacing.small),
            populationIcon.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: ThemeManager.Spacing.medium),
            populationIcon.widthAnchor.constraint(equalToConstant: 24),
            populationIcon.heightAnchor.constraint(equalToConstant: 16),
            populationIcon.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ThemeManager.Spacing.medium),

            populationLabel.centerYAnchor.constraint(equalTo: populationIcon.centerYAnchor),
            populationLabel.leadingAnchor.constraint(equalTo: populationIcon.trailingAnchor, constant: ThemeManager.Spacing.small),
            populationLabel.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -ThemeManager.Spacing.medium),

            removeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            removeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ThemeManager.Spacing.medium),
            removeButton.widthAnchor.constraint(equalToConstant: 24),
            removeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    /// Format population number with proper suffix (K, M, B)
    private func formatPopulation(_ population: Int) -> String {
        let number = Double(population)
        let thousand = number / 1000
        let million = number / 1000000
        let billion = number / 1000000000

        if billion >= 1.0 {
            return String(format: "%.1fB", billion)
        } else if million >= 1.0 {
            return String(format: "%.1fM", million)
        } else if thousand >= 1.0 {
            return String(format: "%.1fK", thousand)
        } else {
            return "\(population)"
        }
    }

    // MARK: - Actions
    @objc private func removeButtonTapped() {
        onRemove?()
    }

    // MARK: - Public Methods
    /// Configure cell with city data
    /// - Parameters:
    ///   - city: City model to display
    ///   - onRemove: Callback for remove action
    ///   - isRecentCity: Whether this cell is in recent cities list
    func configure(with city: SearchResult, onRemove: (() -> Void)? = nil, isRecentCity: Bool = false) {
        self.onRemove = onRemove
        self.isRecentCity = isRecentCity
        
        // Update remove button state
        removeButton.isHidden = !isRecentCity
        removeButton.isUserInteractionEnabled = isRecentCity
        removeButton.tintColor = isRecentCity ? 
            ThemeManager.shared.textColor.withAlphaComponent(0.6) : 
            ThemeManager.shared.textColor.withAlphaComponent(0.3)
        
        cityLabel.text = city.areaName?.first?.value
        regionLabel.text = city.region?.first?.value
        countryLabel.text = city.country?.first?.value

        if let latitude = Double(city.latitude ?? ""), let longitude = Double(city.longitude ?? "") {
            latLongLabel.text = String(format: "%.2f, %.2f", latitude, longitude)
        } else {
            latLongLabel.text = "Invalid coordinates"
        }

        // Configure population
        if let population = Int(city.population ?? "") {
            populationLabel.text = formatPopulation(population)
            populationIcon.isHidden = false
            populationLabel.isHidden = false
        } else {
            populationIcon.isHidden = true
            populationLabel.isHidden = true
        }

        // Apply theme colors
        containerView.backgroundColor = ThemeManager.shared.backgroundColor.withAlphaComponent(0.6)
        locationIcon.tintColor = ThemeManager.shared.textColor
        cityLabel.textColor = ThemeManager.shared.textColor
        regionLabel.textColor = ThemeManager.shared.textColor.withAlphaComponent(0.8)
        countryLabel.textColor = ThemeManager.shared.textColor.withAlphaComponent(0.8)
        latLongLabel.textColor = ThemeManager.shared.textColor.withAlphaComponent(0.6)
        populationIcon.tintColor = ThemeManager.shared.textColor.withAlphaComponent(0.8)
        populationLabel.textColor = ThemeManager.shared.textColor.withAlphaComponent(0.8)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cityLabel.text = nil
        regionLabel.text = nil
        countryLabel.text = nil
        latLongLabel.text = nil
        populationLabel.text = nil
        populationIcon.isHidden = true
        populationLabel.isHidden = true
        removeButton.isHidden = true
        removeButton.isUserInteractionEnabled = false
        isRecentCity = false
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        containerView.layer.shadowColor = UIColor.black.cgColor
    }
}

import UIKit

final class CityCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "CityCell"

    var onRemove: (() -> Void)?
    private var isRecentCity: Bool = false

    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.Color.backgroundColor.withAlphaComponent(0.6)
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
        imageView.tintColor = ThemeManager.Color.textColor
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

    private var populationIcon: UIImageView?
    private var populationLabel: UILabel?

    private lazy var removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = ThemeManager.Color.textColor.withAlphaComponent(0.6)
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

            removeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            removeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ThemeManager.Spacing.medium),
            removeButton.widthAnchor.constraint(equalToConstant: 24),
            removeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    private func setupPopulationViews() {
        guard populationIcon == nil, populationLabel == nil else { return }
        
        let icon = UIImageView(image: UIImage(systemName: "person.3.fill"))
        icon.tintColor = ThemeManager.Color.textColor.withAlphaComponent(0.8)
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.font = ThemeManager.Fonts.caption
        label.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(icon)
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: latLongLabel.bottomAnchor, constant: ThemeManager.Spacing.small),
            icon.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: ThemeManager.Spacing.medium),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 16),
            icon.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ThemeManager.Spacing.medium),
            
            label.centerYAnchor.constraint(equalTo: icon.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: ThemeManager.Spacing.small),
            label.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -ThemeManager.Spacing.medium)
        ])
        
        populationIcon = icon
        populationLabel = label
    }

    // MARK: - Actions
    @objc private func removeButtonTapped() {
        onRemove?()
    }

    // MARK: - Public Methods
    func configure(with city: SearchResult, onRemove: (() -> Void)? = nil, isRecentCity: Bool = false) {
        self.onRemove = onRemove
        self.isRecentCity = isRecentCity
        
        // Update remove button state
        removeButton.isHidden = !isRecentCity
        removeButton.isUserInteractionEnabled = isRecentCity
        removeButton.tintColor = isRecentCity ? 
            ThemeManager.Color.textColor.withAlphaComponent(0.6) : 
            ThemeManager.Color.textColor.withAlphaComponent(0.3)
        
        cityLabel.text = city.areaName?.first?.value
        regionLabel.text = city.region?.first?.value
        countryLabel.text = city.country?.first?.value

        if let latitude = Double(city.latitude ?? ""), let longitude = Double(city.longitude ?? "") {
            latLongLabel.text = String(format: "%.2f, %.2f", latitude, longitude)
        } else {
            latLongLabel.text = "Invalid coordinates"
        }

        // Configure population
        if let population = Double(city.population ?? "") {
            setupPopulationViews()
            populationLabel?.text = population.formatPopulation()
            populationIcon?.isHidden = false
            populationLabel?.isHidden = false
        } else {
            populationIcon?.isHidden = true
            populationLabel?.isHidden = true
        }

        // Apply theme colors
        containerView.backgroundColor = ThemeManager.Color.backgroundColor.withAlphaComponent(0.6)
        locationIcon.tintColor = ThemeManager.Color.textColor
        cityLabel.textColor = ThemeManager.Color.textColor
        regionLabel.textColor = ThemeManager.Color.textColor.withAlphaComponent(0.8)
        countryLabel.textColor = ThemeManager.Color.textColor.withAlphaComponent(0.8)
        latLongLabel.textColor = ThemeManager.Color.textColor.withAlphaComponent(0.6)
        populationIcon?.tintColor = ThemeManager.Color.textColor.withAlphaComponent(0.8)
        populationLabel?.textColor = ThemeManager.Color.textColor.withAlphaComponent(0.8)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cityLabel.text = nil
        regionLabel.text = nil
        countryLabel.text = nil
        latLongLabel.text = nil
        populationLabel?.text = nil
        populationIcon?.isHidden = true
        populationLabel?.isHidden = true
        removeButton.isHidden = true
        removeButton.isUserInteractionEnabled = false
        isRecentCity = false
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        containerView.layer.shadowColor = UIColor.black.cgColor
    }
}

import UIKit

/// Cell for displaying city information
final class CityCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "CityCell"

    // MARK: - UI Components
    private lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeManager.Fonts.body
        label.textColor = ThemeManager.shared.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var countryLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeManager.Fonts.caption
        label.textColor = ThemeManager.shared.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        backgroundColor = ThemeManager.shared.backgroundColor
        selectionStyle = .none

        // Add subviews
        contentView.addSubview(cityLabel)
        contentView.addSubview(countryLabel)

        // Setup constraints
        NSLayoutConstraint.activate([
            cityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ThemeManager.Spacing.small),
            cityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ThemeManager.Spacing.medium),
            cityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ThemeManager.Spacing.medium),

            countryLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: ThemeManager.Spacing.small),
            countryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ThemeManager.Spacing.medium),
            countryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ThemeManager.Spacing.medium),
            countryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ThemeManager.Spacing.small)
        ])
    }

    // MARK: - Public Methods
    /// Configure cell with city data
    /// - Parameter city: City model to display
    func configure(with city: SearchResult) {
        cityLabel.text = city.areaName?.first?.value
        countryLabel.text = city.country?.first?.value
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cityLabel.text = nil
        countryLabel.text = nil
    }
}

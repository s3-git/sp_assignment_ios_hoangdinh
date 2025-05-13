import SwiftUI

/// A reusable row component for displaying weather metrics
/// - Note: This component provides a consistent layout for displaying weather information with an icon, value, and label
struct WeatherRow: View {
    // MARK: - Properties
    let icon: String
    let value: String
    let label: String

    // MARK: - Initialization
    /// Creates a new WeatherRow
    /// - Parameters:
    ///   - icon: The SF Symbol name for the row's icon
    ///   - value: The value to display
    ///   - label: The label describing the value
    init(icon: String, value: String, label: String) {
        self.icon = icon
        self.value = value
        self.label = label
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 20)
            Text(value)
            Spacer()
            Text(label)
                .foregroundStyle(ThemeManager.shared.textColor.toColor.opacity(0.6))
        }
        .font(Font(ThemeManager.Fonts.body))
    }
} 
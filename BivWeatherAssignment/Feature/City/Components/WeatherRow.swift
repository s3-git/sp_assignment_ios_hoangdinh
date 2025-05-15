import SwiftUI

struct WeatherRow: View {
    // MARK: - Properties
    let icon: String
    let value: String
    let label: String

    // MARK: - Initialization
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
            Text(label)
                .foregroundStyle(ThemeManager.Color.textColor.toColor.opacity(0.6))
            Spacer()
            Text(value)
        }
        .font(Font(ThemeManager.Fonts.body))
    }
}

import SwiftUI

struct WeatherInfoCard<Content: View>: View {
    // MARK: - Properties
    let title: String
    let systemImage: String
    let content: Content

    // MARK: - Initialization
    init(title: String, systemImage: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(ThemeManager.Color.textColor.toColor)
                Text(title)
                    .font(Font(ThemeManager.Fonts.headline))
                    .foregroundStyle(ThemeManager.Color.textColor.toColor)
            }
            content
                .foregroundStyle(ThemeManager.Color.textColor.toColor)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ThemeManager.Color.textColor.toColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityIdentifier(title)
    }
}

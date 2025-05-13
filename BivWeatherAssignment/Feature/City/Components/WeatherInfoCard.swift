import SwiftUI

/// A reusable card component for displaying weather information
/// - Note: This component provides a consistent card layout with a title, icon, and custom content
struct WeatherInfoCard<Content: View>: View {
    // MARK: - Properties
    let title: String
    let systemImage: String
    let content: Content

    // MARK: - Initialization
    /// Creates a new WeatherInfoCard
    /// - Parameters:
    ///   - title: The title of the card
    ///   - systemImage: The SF Symbol name for the card's icon
    ///   - content: A closure that provides the card's content
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
                    .foregroundStyle(ThemeManager.shared.textColor.toColor)
                Text(title)
                    .font(Font(ThemeManager.Fonts.headline))
                    .foregroundStyle(ThemeManager.shared.textColor.toColor)
            }
            content
                .foregroundStyle(ThemeManager.shared.textColor.toColor)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ThemeManager.shared.textColor.toColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
} 
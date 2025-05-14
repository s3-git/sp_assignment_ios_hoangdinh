import SwiftUI

// MARK: - Weather Card
struct WeatherCard: View {
    let temperature: String
    let description: String
    let humidity: String
    let iconURL: URL?

    var body: some View {
        VStack(spacing: AppConstants.UserInterface.padding) {
            if let iconURL = iconURL {
                AsyncImage(url: iconURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                        .tint(ThemeManager.shared.accentColor.toColor)
                }
                .frame(width: 100, height: 100)
            }

            Text(temperature)
                .font(Font(ThemeManager.Fonts.title))
                .foregroundStyle(ThemeManager.shared.textColor.toColor)

            Text(description)
                .font(Font(ThemeManager.Fonts.headline))
                .foregroundStyle(ThemeManager.shared.secondary.toColor)

            HStack {
                Image(systemName: "humidity")
                Text(humidity)
            }
            .font(Font(ThemeManager.Fonts.body))
            .foregroundStyle(ThemeManager.shared.secondary.toColor)
        }
        .padding(AppConstants.UserInterface.padding)
        .background(ThemeManager.shared.backgroundColor.toColor)
        .cornerRadius(AppConstants.UserInterface.cornerRadius)
        .shadow(
            color: ThemeManager.shared.shadowColor.toColor.opacity(0.1),
            radius: AppConstants.UserInterface.padding * 0.625,
            x: 0,
            y: AppConstants.UserInterface.padding * 0.3125
        )
    }
}

// MARK: - Preview Provider
struct WeatherComponents_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeatherCard(
                temperature: "23°C",
                description: "Sunny",
                humidity: "65%",
                iconURL: nil
            )
            .previewLayout(.sizeThatFits)
            .applyTheme()

            EmptyStateView(
                title: "No Cities",
                message: "Search for a city to see its weather",
                systemImage: "magnifyingglass",
                action: {},
                actionTitle: "Search"
            )
            .previewLayout(.sizeThatFits)
            .applyTheme()

            LoadingView(message: "Loading weather data...")
                .previewLayout(.sizeThatFits)
                .applyTheme()

            ErrorView(
                error: "Failed to load weather data",
                retryAction: {}
            )
            .previewLayout(.sizeThatFits)
            .applyTheme()
        }
    }
}

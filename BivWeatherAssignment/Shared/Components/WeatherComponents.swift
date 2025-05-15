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
                        .tint(ThemeManager.Color.accentColor.toColor)
                }
                .frame(width: 100, height: 100)
            }

            Text(temperature)
                .font(Font(ThemeManager.Fonts.title))
                .foregroundStyle(ThemeManager.Color.textColor.toColor)

            Text(description)
                .font(Font(ThemeManager.Fonts.headline))
                .foregroundStyle(ThemeManager.Color.secondary.toColor)

            HStack {
                Image(systemName: "humidity")
                Text(humidity)
            }
            .font(Font(ThemeManager.Fonts.body))
            .foregroundStyle(ThemeManager.Color.secondary.toColor)
        }
        .padding(AppConstants.UserInterface.padding)
        .background(ThemeManager.Color.backgroundColor.toColor)
        .cornerRadius(AppConstants.UserInterface.cornerRadius)
        .shadow(
            color: ThemeManager.Color.shadowColor.toColor.opacity(0.1),
            radius: AppConstants.UserInterface.padding * 0.625,
            x: 0,
            y: AppConstants.UserInterface.padding * 0.3125
        )
    }
}

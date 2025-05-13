import SwiftUI

/// A view component for displaying hourly weather forecast information
/// - Note: This component displays time, weather icon, temperature, chance of rain, and wind speed for a specific hour
struct HourlyForecastView: View {
    // MARK: - Properties
    let forecast: HourlyForecast

    // MARK: - Initialization
    /// Creates a new HourlyForecastView
    /// - Parameter forecast: The hourly forecast data to display
    init(forecast: HourlyForecast) {
        self.forecast = forecast
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            // Time
            Text(forecast.time)
                .font(Font(ThemeManager.Fonts.caption))
                .foregroundStyle(ThemeManager.shared.textColor.toColor)
                .padding(.top, 8)

            // Weather Icon
            if let iconURL = URL(string: forecast.weatherIconURL) {
                AsyncImage(url: iconURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .shadow(radius: 2)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 60)
            }

            // Temperature
            Text(forecast.temperature.components(separatedBy: ",").first ?? "")
                .font(Font(ThemeManager.Fonts.body))
                .foregroundStyle(ThemeManager.shared.textColor.toColor)
                .fontWeight(.semibold)
                .padding(.vertical, 4)

            Divider()
                .frame(height: 1)
                .background(ThemeManager.shared.textColor.toColor.opacity(0.1))
                .padding(.horizontal, 12)

            // Rain Chance
            HStack(spacing: 6) {
                Image(systemName: "drop.fill")
                    .foregroundStyle(Color.blue)
                    .font(.system(size: 14))
                Text(forecast.chanceOfRain)
            }
            .font(Font(ThemeManager.Fonts.caption))
            .padding(.vertical, 4)

            // Wind Speed
            Text(forecast.windSpeed)
                .font(Font(ThemeManager.Fonts.caption))
                .foregroundStyle(ThemeManager.shared.textColor.toColor.opacity(0.8))
                .padding(.bottom, 8)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .frame(width: 130, height: 240)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ThemeManager.shared.textColor.toColor.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(ThemeManager.shared.textColor.toColor.opacity(0.1), lineWidth: 1)
        )
    }
}

import SwiftUI

/// View for displaying city weather information
struct CityView: View {
    // MARK: - Properties
    @StateObject private var viewModel: CityViewModel

    // MARK: - Initialization
    init(viewModel: CityViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        BaseView {
            if let weatherData = $viewModel.weatherData.wrappedValue {
                WeatherContentView(weatherData: weatherData).background(ThemeManager.shared.backgroundColor.toColor)
            }
        }.padding()
        .onAppear {
            viewModel.fetchWeatherData()
        }
    }
}
/// View for displaying weather content
struct WeatherContentView: View {
    // MARK: - Properties
    private let weatherData: WeatherPresenterProtocol

    // MARK: - Initialization
    init(weatherData: WeatherPresenterProtocol) {
        self.weatherData = weatherData
    }

    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Location Header
            VStack(spacing: 8) {
                Text(weatherData.areaName)
                    .font(Font(ThemeManager.Fonts.title))
                    .foregroundStyle(ThemeManager.shared.textColor.toColor)

                HStack(spacing: 4) {
                    Text(weatherData.regionName)
                    Text("•")
                    Text(weatherData.countryName)
                }
                .font(Font(ThemeManager.Fonts.body))
                .foregroundStyle(ThemeManager.shared.textColor.toColor.opacity(0.8))
            }
            .padding(.top)

            // MARK: - Weather Icon and Description
            VStack(spacing: 16) {
                if let weatherIconURL = URL(string: weatherData.imageURL) {
                    AsyncImage(url: weatherIconURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .shadow(radius: 4)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 120, height: 120)
                }

                Text(weatherData.weatherDesc)
                    .font(Font(ThemeManager.Fonts.headline))
                    .foregroundStyle(ThemeManager.shared.textColor.toColor)
                    .multilineTextAlignment(.center)
            }

            // MARK: - Temperature Card
            WeatherInfoCard(title: "Temperature", systemImage: "thermometer") {
                VStack(spacing: 12) {
                    Text(weatherData.temperature)
                        .font(Font(ThemeManager.Fonts.title))
                    Text(weatherData.feelsLike)
                        .font(Font(ThemeManager.Fonts.body))
                }
            }

            // MARK: - Wind Card
            WeatherInfoCard(title: "Wind", systemImage: "wind") {
                VStack(spacing: 12) {
                    Text(weatherData.windSpeed)
                        .font(Font(ThemeManager.Fonts.title))
                    Text(weatherData.windDirection)
                        .font(Font(ThemeManager.Fonts.body))
                }
            }

            // MARK: - Atmospheric Conditions Card
            WeatherInfoCard(title: "Atmospheric Conditions", systemImage: "barometer") {
                VStack(spacing: 12) {
                    WeatherRow(icon: "humidity.fill", value: weatherData.humidity, label: "Humidity")
                    WeatherRow(icon: "gauge", value: weatherData.pressure, label: "Pressure")
                    WeatherRow(icon: "eye.fill", value: weatherData.visibility, label: "Visibility")
                    WeatherRow(icon: "cloud.fill", value: weatherData.cloudCover, label: "Cloud Cover")
                    WeatherRow(icon: "drop.fill", value: weatherData.precipitation, label: "Precipitation")
                }
            }

            // MARK: - UV and Time Info Card
            WeatherInfoCard(title: "Additional Info", systemImage: "info.circle") {
                VStack(spacing: 12) {
                    WeatherRow(icon: "sun.max.fill", value: weatherData.uvIndex, label: "UV Index")
                    WeatherRow(icon: "clock.fill", value: weatherData.localTime, label: "Local Time")
                    WeatherRow(icon: "calendar", value: weatherData.observationTime, label: "Last Updated")
                }
            }

            // MARK: - Hourly Forecast
            if !weatherData.forecastDays.isEmpty {
                WeatherInfoCard(title: "Today's Forecast", systemImage: "clock") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(weatherData.forecastDays[0].hourlyForecasts, id: \.time) { hourly in
                                HourlyForecastView(forecast: hourly)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
        }
        .padding()
    }
}

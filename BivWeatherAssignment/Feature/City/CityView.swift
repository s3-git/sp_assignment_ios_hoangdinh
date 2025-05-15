import SwiftUI

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
            switch viewModel.state {
                case .loading:
                    ProgressView()
                case .error(let message):
                    ErrorView(error: message, retryAction: {
                        viewModel.fetchWeatherData(forceRefresh: true)
                    })
                case .success:
                    if let weatherData = viewModel.weatherData {
                        WeatherContentView(city: viewModel.city, weatherData: weatherData, onRefresh: {
                            viewModel.fetchWeatherData(forceRefresh: true)
                        }).padding(.top, viewModel.navBarHeight)
                    } else {
                        EmptyStateView(
                            title: "No Weather Data",
                            message: "Unable to load weather information. Please try again.",
                            systemImage: "cloud.slash",
                            action: {
                                viewModel.fetchWeatherData(forceRefresh: true)
                            },
                            actionTitle: "Retry"
                        )
                    }
                default:
                    EmptyStateView(
                        title: "No Data",
                        message: "Please wait while we load the weather information.",
                        systemImage: "hourglass"
                    )
            }
            
        }
        .safeAreaPadding(.all)
        .onAppear {
            viewModel.fetchWeatherData()
        }
    }
}

struct WeatherContentView: View {
    // MARK: - Properties
    private let city: SearchResult
    private let weatherData: WeatherData
    @State private var isRefreshing = false
    var onRefresh: () -> Void
    
    // MARK: - Initialization

    init(city: SearchResult, weatherData: WeatherData, onRefresh: @escaping () -> Void) {
        self.city = city
        self.weatherData = weatherData
        self.onRefresh = onRefresh
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // MARK: - Location and Weather Overview
                locationAndWeatherView
                    .padding(.top)
                
                // MARK: - Temperature and Wind
                HStack(spacing: 16) {
                    temperatureCard
                    windCard
                }
                
                // MARK: - Atmospheric and Additional Info
                atmosphericCard
                additionalInfoCard
            }
        }
        .refreshable {
            // Perform refresh
            isRefreshing = true
            onRefresh()
            // Add slight delay for better UX
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            isRefreshing = false
        }
        .accessibilityIdentifier("weatherDetails")
    }
    
    // MARK: - Location and Weather View
    private var locationAndWeatherView: some View {
        VStack(spacing: 12) {
            // Location Info
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(ThemeManager.Color.textColor.toColor)
                
                Text(city.areaName?.first?.value ?? weatherData.areaName)
                    .foregroundStyle(ThemeManager.Color.textColor.toColor)
                    .font(Font(ThemeManager.Fonts.title))
                    .fontWeight(.bold)
            }
            
            Text("\(city.region?.first?.value ?? weatherData.regionName) • \(city.country?.first?.value ?? weatherData.countryName)")
                .font(Font(ThemeManager.Fonts.caption))
                .foregroundStyle(ThemeManager.Color.textColor.toColor.opacity(0.7))
            
            // Weather Icon and Description
            if let weatherIconURL = URL(string: weatherData.imageURL) {
                AsyncImage(url: weatherIconURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                } placeholder: {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            
            Text(weatherData.weatherDesc)
                .font(Font(ThemeManager.Fonts.headline))
                .foregroundStyle(ThemeManager.Color.textColor.toColor)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ThemeManager.Color.textColor.toColor.opacity(0.05))
        )
    }
    
    // MARK: - Temperature Card
    private var temperatureCard: some View {
        WeatherInfoCard(title: "Temperature", systemImage: "thermometer") {
            VStack(spacing: 12) {
                Text(weatherData.temperature)
                    .font(Font(ThemeManager.Fonts.title))
                    .fontWeight(.bold)
                Text(weatherData.feelsLike)
                    .font(Font(ThemeManager.Fonts.body))
            }
        }
    }
    
    // MARK: - Wind Card
    private var windCard: some View {
        WeatherInfoCard(title: "Wind", systemImage: "wind") {
            VStack(spacing: 12) {
                Text(weatherData.windSpeed)
                    .font(Font(ThemeManager.Fonts.title))
                    .fontWeight(.bold)
                Text(weatherData.windDirection)
                    .font(Font(ThemeManager.Fonts.body))
            }
        }
    }
    
    // MARK: - Atmospheric Card
    private var atmosphericCard: some View {
        WeatherInfoCard(title: "Atmospheric", systemImage: "barometer") {
            VStack(spacing: 8) {
                WeatherRow(icon: "humidity.fill", value: weatherData.humidity, label: "Humidity")
                WeatherRow(icon: "gauge", value: weatherData.pressure, label: "Pressure")
                WeatherRow(icon: "eye.fill", value: weatherData.visibility, label: "Visibility")
            }
        }
    }
    
    // MARK: - Additional Info Card
    private var additionalInfoCard: some View {
        WeatherInfoCard(title: "Additional", systemImage: "info.circle") {
            VStack(spacing: 8) {
                WeatherRow(icon: "sun.max.fill", value: weatherData.uvIndex, label: "UV")
                WeatherRow(icon: "clock.fill", value: weatherData.localTime, label: "Time")
            }
        }
    }
}

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
/// presenter view protocol
protocol WeatherPresenterProtocol {
    var areaName: String { get }
    var weatherDesc: String { get }
    var regionName: String { get }
    var countryName: String { get }
    var localTime: String { get }
    var imageURL: String { get }
    var temperature: String { get }
    var humidity: String { get }
}
/// View for displaying weather content
private struct WeatherContentView: View {
    let weatherData: WeatherPresenterProtocol

    var body: some View {
        VStack(spacing: 20) {
            Text(weatherData.areaName)
                .font(Font(ThemeManager.Fonts.title))
                .foregroundStyle(ThemeManager.shared.textColor.toColor)

                .multilineTextAlignment(.leading)
            Text(weatherData.regionName)
                .font(Font(ThemeManager.Fonts.body))
                .foregroundStyle(ThemeManager.shared.textColor.toColor)

                .multilineTextAlignment(.leading)
            Text(weatherData.countryName)
                .font(Font(ThemeManager.Fonts.body))
                .foregroundStyle(ThemeManager.shared.textColor.toColor)

                .multilineTextAlignment(.trailing)

            // Weather Image
            if let weatherIconURL = URL(string: weatherData.imageURL) {
                AsyncImage(url: weatherIconURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 80)

            }
            Text(weatherData.weatherDesc)
                .font(Font(ThemeManager.Fonts.headline))
                .foregroundStyle(ThemeManager.shared.textColor.toColor)

                .multilineTextAlignment(.trailing)

            Text("Local time is \(weatherData.localTime)")
                .font(Font(ThemeManager.Fonts.caption))
                .foregroundStyle(ThemeManager.shared.textColor.toColor)

                .multilineTextAlignment(.center)

            // Weather Information
            VStack(spacing: 12) {
                Text(weatherData.temperature)
                    .font(Font(ThemeManager.Fonts.caption))
                    .foregroundStyle(ThemeManager.shared.textColor.toColor)

                HStack {
                    Image(systemName: "humidity")
                    Text(weatherData.humidity)

                        .font(Font(ThemeManager.Fonts.caption))
                        .foregroundStyle(ThemeManager.shared.textColor.toColor)

                }
            }
            .padding()
            Spacer()
        }
        .padding()
    }
}

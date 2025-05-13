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

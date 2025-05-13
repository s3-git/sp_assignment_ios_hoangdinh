import Foundation

/// App-wide constants
enum AppConstants {
    // MARK: - API
    enum Network {
        static let baseURL = "https://api.worldweatheronline.com/premium/v1"
        static let timeoutInterval: TimeInterval = 30
        static let memoryCacheSize = 50_000_000 // 50MB
        static let diskCacheSize = 100_000_000  // 100MB
    }

    // MARK: - Cache
    enum Cache {
        static let expirationInterval: TimeInterval = 60 // 1 minute
        static let weatherDataKey = "weather_data"
        static let searchHistoryKey = "search_history"
        static let maxSearchHistoryItems = 10
    }

    // MARK: - UI
    enum UserInterface {
        static let cornerRadius: CGFloat = 16
        static let padding: CGFloat = 16
        static let animationDuration: Double = 0.3
        static let errorDisplayDuration: TimeInterval = 3
        static let searchDebounceInterval: Int = 500
        static let maxRecentCities = 10
    }

    // MARK: - Weather
    enum Weather {
        static let defaultUnit = "metric"
        static let defaultLanguage = "en"
        static let refreshInterval: TimeInterval = 300 // 5 minutes
    }

    // MARK: - Validation
    enum Validation {
        static let minSearchLength = 2
        static let maxSearchLength = 50
    }

    // MARK: - Error Messages
    enum ErrorMessages {
        static let networkError = "Unable to connect to the server. Please check your internet connection."
        static let invalidResponse = "Received invalid response from the server."
        static let invalidData = "Received invalid data from the server."
        static let locationError = "Unable to access your location. Please enable location services."
        static let searchError = "Please enter a valid city name."
    }

    // MARK: - Keys
    enum Assets {
        static let imgBackground = "img_background"
        static let icCenter = "ic_center"
        static let imgBackgroundCell = "img_background_cell"
    }
}

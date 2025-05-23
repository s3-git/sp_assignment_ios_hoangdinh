import Foundation

enum AppConstants {
    // MARK: - API
    struct Environment {
        static let apiKey: String = "912f884e51f64c66b5643355251205"
        static let baseURL: String = "https://api.worldweatheronline.com/premium/v1"
    }

    enum Network {
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

    // MARK: - Keys
    enum Assets {
        static let imgBackground = "img_background"
        static let icCenter = "ic_center"
        static let imgBackgroundCell = "img_background_cell"
    }
}

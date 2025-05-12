import Foundation

/// Application-wide error types
enum AppError: LocalizedError {
    // MARK: - Network Errors
    case networkError(Error)
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)

    // MARK: - Data Persistence Errors
    case persistenceError(String)
    case dataNotFound
    case invalidData
    case saveFailed(String)

    // MARK: - City Search Errors
    case cityNotFound
    case invalidSearchQuery
    case tooManyResults
    case searchLimitExceeded

    // MARK: - Weather Data Errors
    case weatherDataUnavailable
    case locationNotAvailable
    case invalidCoordinates

    // MARK: - User Defaults Errors
    case userDefaultsError(String)
    case userDefaultsKeyNotFound(String)

    // MARK: - Localized Description
    var errorDescription: String? {
        switch self {
        // Network Errors
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid URL provided"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"

        // Data Persistence Errors
        case .persistenceError(let message):
            return "Persistence error: \(message)"
        case .dataNotFound:
            return "Requested data not found"
        case .invalidData:
            return "Data is invalid or corrupted"
        case .saveFailed(let reason):
            return "Failed to save data: \(reason)"

        // City Search Errors
        case .cityNotFound:
            return "No cities found matching your search"
        case .invalidSearchQuery:
            return "Invalid search query. Please try again"
        case .tooManyResults:
            return "Too many results. Please be more specific"
        case .searchLimitExceeded:
            return "Search limit exceeded. Please try again later"

        // Weather Data Errors
        case .weatherDataUnavailable:
            return "Weather data is currently unavailable"
        case .locationNotAvailable:
            return "Location services are not available"
        case .invalidCoordinates:
            return "Invalid coordinates provided"

        // User Defaults Errors
        case .userDefaultsError(let message):
            return "UserDefaults error: \(message)"
        case .userDefaultsKeyNotFound(let key):
            return "UserDefaults key not found: \(key)"
        }
    }

    // MARK: - Recovery Suggestions
    var recoverySuggestion: String? {
        switch self {
        // Network Errors
        case .networkError:
            return "Please check your internet connection and try again"
        case .invalidURL:
            return "Please verify the URL and try again"
        case .invalidResponse, .httpError:
            return "Please try again later. If the problem persists, contact support"
        case .decodingError:
            return "Please update the app to the latest version"

        // Data Persistence Errors
        case .persistenceError, .invalidData:
            return "Try clearing app data and restarting the app"
        case .dataNotFound:
            return "Please refresh the data or try your search again"
        case .saveFailed:
            return "Please ensure you have enough storage space and try again"

        // City Search Errors
        case .cityNotFound:
            return "Try searching with a different city name or spelling"
        case .invalidSearchQuery:
            return "Enter at least 2 characters for search"
        case .tooManyResults:
            return "Add more characters to narrow down your search"
        case .searchLimitExceeded:
            return "Wait a few minutes before trying again"

        // Weather Data Errors
        case .weatherDataUnavailable:
            return "Try refreshing or check back later"
        case .locationNotAvailable:
            return "Enable location services in Settings to use this feature"
        case .invalidCoordinates:
            return "Please select a valid location"

        // User Defaults Errors
        case .userDefaultsError, .userDefaultsKeyNotFound:
            return "Try clearing app data or reinstalling the app"
        }
    }

    // MARK: - Error Handling Helper
    /// Convert any error to AppError
    static func handle(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }

        // Handle specific error types
        switch error {
        case let urlError as URLError:
            return .networkError(urlError)
        case let decodingError as DecodingError:
            return .decodingError(decodingError)
        default:
            return .networkError(error)
        }
    }
}

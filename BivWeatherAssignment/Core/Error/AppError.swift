import Foundation

/// Application-wide error types

// MARK: - Supporting Types

/// Network-related errors
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case networkError(Error)
    case decodingError(Error)
    case custom(Error)
    case timeout
    case sslError(Error)
    case rateLimitExceeded
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .custom(let error):
            return "Custom error: \(error.localizedDescription)"
        case .timeout:
            return "Request timed out. Please try again"
        case .sslError(let error):
            return "SSL error: \(error.localizedDescription)"
        case .rateLimitExceeded:
            return "Too many requests. Please try again later"
        }
    }
}

/// Cache-related errors
enum CacheError: Error {
    case cacheMiss
    case cacheExpired
    case invalidCacheData
    case cacheWriteFailed(String)
    case cacheReadFailed(String)
    case cacheClearFailed(String)
    case cacheCorruption
    case insufficientDiskSpace
    case migrationFailed(String)
    
    var localizedDescription: String {
        switch self {
        case .cacheMiss:
            return "Requested data not found in cache"
        case .cacheExpired:
            return "Cached data has expired"
        case .invalidCacheData:
            return "Cached data is invalid or corrupted"
        case .cacheWriteFailed(let reason):
            return "Failed to write to cache: \(reason)"
        case .cacheReadFailed(let reason):
            return "Failed to read from cache: \(reason)"
        case .cacheClearFailed(let reason):
            return "Failed to clear cache: \(reason)"
        case .cacheCorruption:
            return "Cache data is corrupted"
        case .insufficientDiskSpace:
            return "Insufficient disk space for caching"
        case .migrationFailed(let reason):
            return "Cache migration failed: \(reason)"
        }
    }
}

/// Data persistence related errors
enum PersistenceError: Error {
    case persistenceError(String)
    case dataNotFound
    case invalidData
    case saveFailed(String)
    case migrationFailed(String)
    case quotaExceeded
    case fileSystemError(String)
    
    var localizedDescription: String {
        switch self {
        case .persistenceError(let message):
            return "Persistence error: \(message)"
        case .dataNotFound:
            return "Requested data not found"
        case .invalidData:
            return "Data is invalid or corrupted"
        case .saveFailed(let reason):
            return "Failed to save data: \(reason)"
        case .migrationFailed(let reason):
            return "Data migration failed: \(reason)"
        case .quotaExceeded:
            return "Storage quota exceeded"
        case .fileSystemError(let reason):
            return "File system error: \(reason)"
        }
    }
}

/// City search related errors
enum SearchError: Error {
    case cityNotFound
    case invalidSearchQuery
    case tooManyResults
    case searchLimitExceeded
    case invalidCharacters
    case encodingError
    
    var localizedDescription: String {
        switch self {
        case .cityNotFound:
            return "No cities found matching your search"
        case .invalidSearchQuery:
            return "Invalid search query. Please try again"
        case .tooManyResults:
            return "Too many results. Please be more specific"
        case .searchLimitExceeded:
            return "Search limit exceeded. Please try again later"
        case .invalidCharacters:
            return "Search query contains invalid characters"
        case .encodingError:
            return "Failed to process search query encoding"
        }
    }
}

/// Weather data related errors
enum WeatherError: Error {
    case weatherDataUnavailable
    case locationNotAvailable
    case invalidCoordinates
    case partialDataAvailable
    case dataFormatChanged
    case apiVersionMismatch
    
    var localizedDescription: String {
        switch self {
        case .weatherDataUnavailable:
            return "Weather data is currently unavailable"
        case .locationNotAvailable:
            return "Location services are not available"
        case .invalidCoordinates:
            return "Invalid coordinates provided"
        case .partialDataAvailable:
            return "Some weather data is unavailable"
        case .dataFormatChanged:
            return "Weather data format has changed"
        case .apiVersionMismatch:
            return "Weather API version mismatch"
        }
    }
}

/// User defaults related errors
enum StorageError: Error {
    case userDefaultsError(String)
    case userDefaultsKeyNotFound(String)
    
    var localizedDescription: String {
        switch self {
        case .userDefaultsError(let message):
            return "UserDefaults error: \(message)"
        case .userDefaultsKeyNotFound(let key):
            return "UserDefaults key not found: \(key)"
        }
    }
}

enum AppError: LocalizedError {
    // MARK: - Cases
    case network(NetworkError)
    case persistence(PersistenceError)
    case search(SearchError)
    case weather(WeatherError)
    case storage(StorageError)
    case cache(CacheError)
    
    // MARK: - Localized Description
    var errorDescription: String? {
        switch self {
        case .network(let error):
            return error.localizedDescription
        case .persistence(let error):
            return error.localizedDescription
        case .search(let error):
            return error.localizedDescription
        case .weather(let error):
            return error.localizedDescription
        case .storage(let error):
            return error.localizedDescription
        case .cache(let error):
            return error.localizedDescription
        }
    }
    
    // MARK: - Recovery Suggestions
    var recoverySuggestion: String? {
        switch self {
        case .network(let error):
            switch error {
            case .invalidURL:
                return "Please verify the URL and try again"
            case .invalidResponse:
                return "Please try again later. If the problem persists, contact support"
            case .httpError:
                return "Please try again later. If the problem persists, contact support"
            case .decodingError:
                return "Please update the app to the latest version"
            case .networkError:
                return "Please check your internet connection and try again"
            case .custom:
                return "Please try again later"
            case .timeout:
                return "Please try again later"
            case .sslError:
                return "Please check your internet connection and try again"
            case .rateLimitExceeded:
                return "Please try again later"
            }
        case .persistence(let error):
            switch error {
            case .persistenceError, .invalidData:
                return "Try clearing app data and restarting the app"
            case .dataNotFound:
                return "Please refresh the data or try your search again"
            case .saveFailed:
                return "Please ensure you have enough storage space and try again"
            case .migrationFailed:
                return "Try clearing app data and restarting the app"
            case .quotaExceeded:
                return "Please free up storage space and try again"
            case .fileSystemError:
                return "Please check your file system and try again"
            }
        case .search(let error):
            switch error {
            case .cityNotFound:
                return "Try searching with a different city name or spelling"
            case .invalidSearchQuery:
                return "Enter at least 2 characters for search"
            case .tooManyResults:
                return "Add more characters to narrow down your search"
            case .searchLimitExceeded:
                return "Wait a few minutes before trying again"
            case .invalidCharacters:
                return "Search query contains invalid characters"
            case .encodingError:
                return "Please update the app to the latest version"
            }
        case .weather(let error):
            switch error {
            case .weatherDataUnavailable:
                return "Try refreshing or check back later"
            case .locationNotAvailable:
                return "Enable location services in Settings to use this feature"
            case .invalidCoordinates:
                return "Please select a valid location"
            case .partialDataAvailable:
                return "Some weather data is unavailable"
            case .dataFormatChanged:
                return "Weather data format has changed"
            case .apiVersionMismatch:
                return "Weather API version mismatch"
            }
        case .storage(let error):
            switch error {
            case .userDefaultsError, .userDefaultsKeyNotFound:
                return "Try clearing app data or reinstalling the app"
            }
        case .cache(let error):
            switch error {
            case .cacheMiss:
                return "Try refreshing the data"
            case .cacheExpired:
                return "Data has expired, refreshing..."
            case .invalidCacheData:
                return "Try clearing the cache and refreshing"
            case .cacheWriteFailed, .cacheReadFailed, .cacheClearFailed:
                return "Try clearing app data or reinstalling the app"
            case .cacheCorruption:
                return "Cache data is corrupted"
            case .insufficientDiskSpace:
                return "Insufficient disk space for caching"
            case .migrationFailed:
                return "Try clearing app data and restarting the app"
            }
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
        case let networkError as NetworkError:
            return .network(networkError)
        case let persistenceError as PersistenceError:
            return .persistence(persistenceError)
        case let searchError as SearchError:
            return .search(searchError)
        case let weatherError as WeatherError:
            return .weather(weatherError)
        case let storageError as StorageError:
            return .storage(storageError)
        case let cacheError as CacheError:
            return .cache(cacheError)
        case let urlError as URLError:
            return .network(.networkError(urlError))
        case let decodingError as DecodingError:
            return .network(.decodingError(decodingError))
        default:
            return .network(.custom(error))
        }
    }
}

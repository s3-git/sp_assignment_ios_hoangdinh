import Combine
import Foundation

/// Service for handling errors consistently across the app
/// This service provides a centralized way to handle, log, and recover from errors
/// It supports various error types including network, persistence, search, weather, and cache errors
protocol ErrorHandlingServiceProtocol {
    /// Handle error and return appropriate user message
    /// - Parameter error: The error to handle
    /// - Returns: A user-friendly error message
    /// - Example:
    /// ```swift
    /// let error = NetworkError.invalidURL
    /// let message = errorHandler.handle(error) // Returns "Invalid URL provided"
    /// showAlert(message: message)
    /// ```
    func handle(_ error: Error) -> String

    /// Get recovery suggestion for an error
    /// - Parameter error: The error to get recovery suggestion for
    /// - Returns: Optional recovery suggestion string
    /// - Example:
    /// ```swift
    /// let error = CacheError.cacheExpired
    /// if let suggestion = errorHandler.getRecoverySuggestion(for: error) {
    ///     showRetryButton(with: suggestion) // "Data has expired, refreshing..."
    /// }
    /// ```
    func getRecoverySuggestion(for error: Error) -> String?

    /// Check if error is recoverable
    /// - Parameter error: The error to check
    /// - Returns: Boolean indicating if the error can be recovered from
    /// - Example:
    /// ```swift
    /// let error = NetworkError.networkError(URLError(.notConnectedToInternet))
    /// if errorHandler.isRecoverable(error) {
    ///     showRetryButton()
    /// } else {
    ///     showContactSupport()
    /// }
    /// ```
    func isRecoverable(_ error: Error) -> Bool

    /// Log error for analytics
    /// - Parameter error: The error to log
    /// - Example:
    /// ```swift
    /// do {
    ///     try await fetchWeatherData()
    /// } catch {
    ///     errorHandler.logError(error)
    ///     // Logs: "Network error: No internet connection"
    ///     // Context: {error_type, error_code, timestamp, is_recoverable, ...}
    /// }
    /// ```
    func logError(_ error: Error)
}

/// Implementation of ErrorHandlingServiceProtocol
/// Provides centralized error handling, logging, and recovery suggestions
final class ErrorHandlingService: ErrorHandlingServiceProtocol {
    // MARK: - Properties
    /// Logger instance for error logging
    private let logger: Logger

    // MARK: - Initialization
    /// Initialize ErrorHandlingService with optional logger
    /// - Parameter logger: Logger instance, defaults to shared instance
    init(logger: Logger = .shared) {
        self.logger = logger
    }

    // MARK: - Public Methods
    /// Handle error and return appropriate user message
    /// Converts any error to a user-friendly message and logs it
    /// - Parameter error: The error to handle
    /// - Returns: A user-friendly error message
    func handle(_ error: Error) -> String {
        let appError = AppError.handle(error)
        logError(appError)
        return appError.localizedDescription
    }

    /// Get recovery suggestion for an error
    /// Provides user-friendly suggestions for error recovery
    /// - Parameter error: The error to get recovery suggestion for
    /// - Returns: Optional recovery suggestion string
    func getRecoverySuggestion(for error: Error) -> String? {
        let appError = AppError.handle(error)
        return appError.recoverySuggestion
    }

    /// Check if error is recoverable
    /// Determines if an error can be recovered from
    /// - Parameter error: The error to check
    /// - Returns: Boolean indicating if the error can be recovered from
    func isRecoverable(_ error: Error) -> Bool {
        let appError = AppError.handle(error)
        return isErrorRecoverable(appError)
    }

    /// Log error for analytics
    /// Logs errors with detailed context for debugging
    /// - Parameter error: The error to log
    func logError(_ error: Error) {
        let appError = AppError.handle(error)
        logger.error("\(appError.localizedDescription)")
        
        let errorContext = createErrorContext(for: appError)
        logger.error("Error Context: \(errorContext)")
    }

    // MARK: - Private Methods
    /// Internal method to check error recoverability
    /// - Parameter error: The AppError to check
    /// - Returns: Boolean indicating if the error can be recovered from
    private func isErrorRecoverable(_ error: AppError) -> Bool {
        switch error {
        case .network(let networkError):
            return isNetworkErrorRecoverable(networkError)
        case .persistence(let persistenceError):
            return isPersistenceErrorRecoverable(persistenceError)
        case .search(let searchError):
            return isSearchErrorRecoverable(searchError)
        case .weather(let weatherError):
            return isWeatherErrorRecoverable(weatherError)
        case .storage:
            return false
        case .cache(let cacheError):
            return isCacheErrorRecoverable(cacheError)
        }
    }

    /// Check if network errors are recoverable
    /// - Parameter error: The NetworkError to check
    /// - Returns: Boolean indicating if the network error can be recovered from
    /// - Note: Recoverable: invalidURL, invalidResponse, httpError, networkError, decodingError, timeout
    /// - Note: Not Recoverable: sslError, rateLimitExceeded, custom
    private func isNetworkErrorRecoverable(_ error: NetworkError) -> Bool {
        switch error {
        case .invalidURL, .invalidResponse, .httpError, .networkError, .decodingError, .timeout:
            return true
        case .sslError, .rateLimitExceeded, .custom:
            return false
        }
    }

    /// Check if persistence errors are recoverable
    /// - Parameter error: The PersistenceError to check
    /// - Returns: Boolean indicating if the persistence error can be recovered from
    /// - Note: Recoverable: persistenceError, dataNotFound, invalidData
    /// - Note: Not Recoverable: saveFailed, migrationFailed, quotaExceeded, fileSystemError
    private func isPersistenceErrorRecoverable(_ error: PersistenceError) -> Bool {
        switch error {
        case .persistenceError, .dataNotFound, .invalidData:
            return true
        case .saveFailed, .migrationFailed, .quotaExceeded, .fileSystemError:
            return false
        }
    }

    /// Check if search errors are recoverable
    /// - Parameter error: The SearchError to check
    /// - Returns: Boolean indicating if the search error can be recovered from
    /// - Note: Recoverable: cityNotFound, invalidSearchQuery, tooManyResults, invalidCharacters
    /// - Note: Not Recoverable: searchLimitExceeded, encodingError
    private func isSearchErrorRecoverable(_ error: SearchError) -> Bool {
        switch error {
        case .cityNotFound, .invalidSearchQuery, .tooManyResults, .invalidCharacters:
            return true
        case .searchLimitExceeded, .encodingError:
            return false
        }
    }

    /// Check if weather errors are recoverable
    /// - Parameter error: The WeatherError to check
    /// - Returns: Boolean indicating if the weather error can be recovered from
    /// - Note: Recoverable: weatherDataUnavailable, partialDataAvailable
    /// - Note: Not Recoverable: locationNotAvailable, invalidCoordinates, dataFormatChanged, apiVersionMismatch
    private func isWeatherErrorRecoverable(_ error: WeatherError) -> Bool {
        switch error {
        case .weatherDataUnavailable, .partialDataAvailable:
            return true
        case .locationNotAvailable, .invalidCoordinates, .dataFormatChanged, .apiVersionMismatch:
            return false
        }
    }

    /// Check if cache errors are recoverable
    /// - Parameter error: The CacheError to check
    /// - Returns: Boolean indicating if the cache error can be recovered from
    /// - Note: Recoverable: cacheMiss, cacheExpired, invalidCacheData
    /// - Note: Not Recoverable: cacheWriteFailed, cacheReadFailed, cacheClearFailed, cacheCorruption, insufficientDiskSpace, migrationFailed
    private func isCacheErrorRecoverable(_ error: CacheError) -> Bool {
        switch error {
        case .cacheMiss, .cacheExpired, .invalidCacheData:
            return true
        case .cacheWriteFailed, .cacheReadFailed, .cacheClearFailed, .cacheCorruption, .insufficientDiskSpace, .migrationFailed:
            return false
        }
    }

    /// Create detailed error context for logging
    /// - Parameter error: The AppError to create context for
    /// - Returns: Dictionary containing error context information
    private func createErrorContext(for error: AppError) -> [String: Any] {
        var context: [String: Any] = [
            "error_type": String(describing: type(of: error)),
            "error_code": getErrorCode(for: error),
            "timestamp": Date().timeIntervalSince1970,
            "is_recoverable": isErrorRecoverable(error)
        ]

        if let recoverySuggestion = error.recoverySuggestion {
            context["recovery_suggestion"] = recoverySuggestion
        }

        addSpecificErrorDetails(to: &context, for: error)
        return context
    }

    /// Add type-specific error details to context
    /// - Parameters:
    ///   - context: The context dictionary to add details to
    ///   - error: The AppError to get details from
    private func addSpecificErrorDetails(to context: inout [String: Any], for error: AppError) {
        switch error {
        case .network(let networkError):
            context["network_error_type"] = String(describing: type(of: networkError))
        case .persistence(let persistenceError):
            context["persistence_error_type"] = String(describing: type(of: persistenceError))
        case .search(let searchError):
            context["search_error_type"] = String(describing: type(of: searchError))
        case .weather(let weatherError):
            context["weather_error_type"] = String(describing: type(of: weatherError))
        case .storage(let storageError):
            context["storage_error_type"] = String(describing: type(of: storageError))
        case .cache(let cacheError):
            context["cache_error_type"] = String(describing: type(of: cacheError))
        }
    }

    /// Generate standardized error code for an error
    /// - Parameter error: The AppError to get code for
    /// - Returns: Standardized error code string
    private func getErrorCode(for error: AppError) -> String {
        switch error {
        case .network(let networkError):
            return getNetworkErrorCode(networkError)
        case .persistence(let persistenceError):
            return getPersistenceErrorCode(persistenceError)
        case .search(let searchError):
            return getSearchErrorCode(searchError)
        case .weather(let weatherError):
            return getWeatherErrorCode(weatherError)
        case .storage(let storageError):
            return getStorageErrorCode(storageError)
        case .cache(let cacheError):
            return getCacheErrorCode(cacheError)
        }
    }

    /// Generate network error code
    /// - Parameter error: The NetworkError to get code for
    /// - Returns: Network error code string
    /// - Note: Codes range from ERR_NETWORK_001 to ERR_NETWORK_006
    private func getNetworkErrorCode(_ error: NetworkError) -> String {
        switch error {
        case .invalidURL: return "ERR_NETWORK_001"
        case .invalidResponse: return "ERR_NETWORK_002"
        case .httpError: return "ERR_NETWORK_003"
        case .networkError: return "ERR_NETWORK_004"
        case .decodingError: return "ERR_NETWORK_005"
        case .timeout: return "ERR_NETWORK_006"
        case .sslError: return "ERR_NETWORK_007"
        case .rateLimitExceeded: return "ERR_NETWORK_008"
        case .custom: return "ERR_NETWORK_009"
        }
    }

    /// Generate persistence error code
    /// - Parameter error: The PersistenceError to get code for
    /// - Returns: Persistence error code string
    /// - Note: Codes range from ERR_DATA_001 to ERR_DATA_004
    private func getPersistenceErrorCode(_ error: PersistenceError) -> String {
        switch error {
        case .persistenceError: return "ERR_DATA_001"
        case .dataNotFound: return "ERR_DATA_002"
        case .invalidData: return "ERR_DATA_003"
        case .saveFailed: return "ERR_DATA_004"
        case .migrationFailed: return "ERR_DATA_005"
        case .quotaExceeded: return "ERR_DATA_006"
        case .fileSystemError: return "ERR_DATA_007"
        }
    }

    /// Generate search error code
    /// - Parameter error: The SearchError to get code for
    /// - Returns: Search error code string
    /// - Note: Codes range from ERR_SEARCH_001 to ERR_SEARCH_004
    private func getSearchErrorCode(_ error: SearchError) -> String {
        switch error {
        case .cityNotFound: return "ERR_SEARCH_001"
        case .invalidSearchQuery: return "ERR_SEARCH_002"
        case .tooManyResults: return "ERR_SEARCH_003"
        case .searchLimitExceeded: return "ERR_SEARCH_004"
        case .invalidCharacters: return "ERR_SEARCH_005"
        case .encodingError: return "ERR_SEARCH_006"
        }
    }

    /// Generate weather error code
    /// - Parameter error: The WeatherError to get code for
    /// - Returns: Weather error code string
    /// - Note: Codes range from ERR_WEATHER_001 to ERR_WEATHER_003
    private func getWeatherErrorCode(_ error: WeatherError) -> String {
        switch error {
        case .weatherDataUnavailable: return "ERR_WEATHER_001"
        case .locationNotAvailable: return "ERR_WEATHER_002"
        case .invalidCoordinates: return "ERR_WEATHER_003"
        case .partialDataAvailable: return "ERR_WEATHER_004"
        case .dataFormatChanged: return "ERR_WEATHER_005"
        case .apiVersionMismatch: return "ERR_WEATHER_006"
        }
    }

    /// Generate storage error code
    /// - Parameter error: The StorageError to get code for
    /// - Returns: Storage error code string
    /// - Note: Codes range from ERR_STORAGE_001 to ERR_STORAGE_002
    private func getStorageErrorCode(_ error: StorageError) -> String {
        switch error {
        case .userDefaultsError: return "ERR_STORAGE_001"
        case .userDefaultsKeyNotFound: return "ERR_STORAGE_002"
        }
    }

    /// Generate cache error code
    /// - Parameter error: The CacheError to get code for
    /// - Returns: Cache error code string
    /// - Note: Codes range from ERR_CACHE_001 to ERR_CACHE_006
    private func getCacheErrorCode(_ error: CacheError) -> String {
        switch error {
        case .cacheMiss: return "ERR_CACHE_001"
        case .cacheExpired: return "ERR_CACHE_002"
        case .invalidCacheData: return "ERR_CACHE_003"
        case .cacheWriteFailed: return "ERR_CACHE_004"
        case .cacheReadFailed: return "ERR_CACHE_005"
        case .cacheClearFailed: return "ERR_CACHE_006"
        case .cacheCorruption: return "ERR_CACHE_007"
        case .insufficientDiskSpace: return "ERR_CACHE_008"
        case .migrationFailed: return "ERR_CACHE_009"
        }
    }
}

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
    /// Create detailed error context for logging
    /// - Parameter error: The AppError to create context for
    /// - Returns: Dictionary containing error context information
    private func createErrorContext(for error: AppError) -> [String: Any] {
        var context: [String: Any] = [
            "error_type": String(describing: type(of: error)),
            "error_code": getErrorCode(for: error),
            "timestamp": Date().timeIntervalSince1970
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

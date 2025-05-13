import Combine
import Foundation

/// Service for handling errors consistently across the app
protocol ErrorHandlingServiceProtocol {
    /// Handle error and return appropriate user message
    func handle(_ error: Error) -> String

    /// Get recovery suggestion for an error
    func getRecoverySuggestion(for error: Error) -> String?

    /// Check if error is recoverable
    func isRecoverable(_ error: Error) -> Bool

    /// Log error for analytics
    func logError(_ error: Error)
}

final class ErrorHandlingService: ErrorHandlingServiceProtocol {
    // MARK: - Properties
    private let logger: Logger

    // MARK: - Initialization
    init(logger: Logger = .shared) {
        self.logger = logger
    }

    // MARK: - Public Methods
    func handle(_ error: Error) -> String {
        let appError = AppError.handle(error)
        logError(appError)
        return appError.localizedDescription
    }

    func getRecoverySuggestion(for error: Error) -> String? {
        let appError = AppError.handle(error)
        return appError.recoverySuggestion
    }

    func isRecoverable(_ error: Error) -> Bool {
        let appError = AppError.handle(error)
        switch appError {
        case .networkError, .invalidResponse, .httpError,
             .persistenceError, .dataNotFound, .invalidData,
             .cityNotFound, .invalidSearchQuery,
             .weatherDataUnavailable:
            return true
        default:
            return false
        }
    }

    func logError(_ error: Error) {
        let appError = AppError.handle(error)
        logger.error("\(appError.localizedDescription)")

        // Add additional error context
        var errorContext: [String: Any] = [
            "error_type": String(describing: type(of: error)),
            "error_code": getErrorCode(for: appError),
            "timestamp": Date().timeIntervalSince1970,
            "is_recoverable": isRecoverable(error)
        ]

        // Add recovery suggestion if available
        if let recoverySuggestion = appError.recoverySuggestion {
            errorContext["recovery_suggestion"] = recoverySuggestion
        }

        // Log error context
        logger.error("Error Context: \(errorContext)")
    }

    // MARK: - Private Methods
    private func getErrorCode(for error: AppError) -> String {
        switch error {
        case .networkError: return "ERR_NETWORK_001"
        case .invalidURL: return "ERR_NETWORK_002"
        case .invalidResponse: return "ERR_NETWORK_003"
        case .httpError: return "ERR_NETWORK_004"
        case .decodingError: return "ERR_NETWORK_005"

        case .persistenceError: return "ERR_DATA_001"
        case .dataNotFound: return "ERR_DATA_002"
        case .invalidData: return "ERR_DATA_003"
        case .saveFailed: return "ERR_DATA_004"

        case .cityNotFound: return "ERR_SEARCH_001"
        case .invalidSearchQuery: return "ERR_SEARCH_002"
        case .tooManyResults: return "ERR_SEARCH_003"
        case .searchLimitExceeded: return "ERR_SEARCH_004"

        case .weatherDataUnavailable: return "ERR_WEATHER_001"
        case .locationNotAvailable: return "ERR_WEATHER_002"
        case .invalidCoordinates: return "ERR_WEATHER_003"

        case .userDefaultsError: return "ERR_STORAGE_001"
        case .userDefaultsKeyNotFound: return "ERR_STORAGE_002"
        }
    }
}

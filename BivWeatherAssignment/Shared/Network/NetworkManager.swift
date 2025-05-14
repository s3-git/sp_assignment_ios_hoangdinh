import Combine
import Foundation

/// NetworkManager handles all network requests in the application
/// Uses Combine framework for reactive programming and CacheManager for response caching
protocol NetworkManagerProtocol {
    func clearCache()
    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, AppError>
    func removeCache(for endpoint: Endpoint)
}

final class NetworkManager: NetworkManagerProtocol {
    // MARK: - Properties
    private let session: URLSession
    private let baseURL: String
    private let cacheManager: CacheManagerProtocol
    private let logger: Logger
    private let errorHandler: ErrorHandlingServiceProtocol

    // MARK: - Initialization
    init(session: URLSession? = .shared, 
         cacheManager: CacheManagerProtocol = CacheManager.shared,
         logger: Logger = Logger.shared,
         errorHandler: ErrorHandlingServiceProtocol = ErrorHandlingService()) {
        self.baseURL = Environment.shared.baseURL
        self.cacheManager = cacheManager
        self.logger = logger
        self.errorHandler = errorHandler

        // Configure URLSession with caching
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = AppConstants.Network.timeoutInterval

        self.session = session ?? URLSession(configuration: configuration)
    }
    
    // MARK: - Public Methods
    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, AppError> {
        guard let url = endpoint.asURL() else {
            let error = AppError.network(.invalidURL)
            errorHandler.logError(error)
            return Fail(error: error).eraseToAnyPublisher()
        }

        // Check cache first
        if let cachedData = cacheManager.getCachedResponse(forKey: url.absoluteString),
           let decodedData = try? JSONDecoder().decode(T.self, from: cachedData), endpoint.cacheTime != 0 {
            logger.info("Cache hit for URL: \(url.absoluteString)")
            return Just(decodedData)
                .setFailureType(to: AppError.self)
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        // Log outgoing request
        logger.logRequest(request)

        return session.dataTaskPublisher(for: request)
            .mapError { [weak self] error -> AppError in
                var appError = AppError.network(.custom(error))

                guard let self = self else { return appError }

                switch error.code {
                    case .timedOut:
                        appError = .network(.timeout)
                    case .secureConnectionFailed:
                        appError = .network(.sslError(error))
                    default:
                        appError = .network(.networkError(error))
                }
                self.errorHandler.logError(appError)
                return appError
            }
            .flatMap { [weak self] data, response -> AnyPublisher<T, AppError> in
                guard let self = self else {
                    return Fail(error: AppError.network(.custom(NSError(domain: "", code: -1)))).eraseToAnyPublisher()
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    let error = AppError.network(.invalidResponse)
                    self.errorHandler.logError(error)
                    return Fail(error: error).eraseToAnyPublisher()
                }

                // Log response
                self.logger.logResponse(httpResponse, data: data)

                // Handle specific HTTP status codes
                switch httpResponse.statusCode {
                case 200...299:
                    // Cache the successful response
                    self.cacheManager.cacheResponse(data, forKey: url.absoluteString, expirationTime: endpoint.cacheTime)
                    self.logger.info("Successfully cached response for URL: \(url.absoluteString)")
                    
                    return Just(data)
                        .decode(type: T.self, decoder: JSONDecoder())
                        .mapError { error -> AppError in
                            let appError = AppError.network(.decodingError(error))
                            self.errorHandler.logError(appError)
                            return appError
                        }
                        .eraseToAnyPublisher()
                        
                case 429:
                    let error = AppError.network(.rateLimitExceeded)
                    self.errorHandler.logError(error)
                    return Fail(error: error).eraseToAnyPublisher()
                    
                default:
                    let error = AppError.network(.httpError(httpResponse.statusCode))
                    self.errorHandler.logError(error)
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Cache Management
    func clearCache() {
        logger.info("Clearing all cache")
        cacheManager.clearRequestCache()
    }

    func removeCache(for endpoint: Endpoint) {
        guard let url = endpoint.asURL() else {
            let error = AppError.cache(.cacheClearFailed("Invalid URL for cache removal"))
            errorHandler.logError(error)
            return
        }
        logger.info("Removing cache for URL: \(url.absoluteString)")
        cacheManager.removeSpecificCache(forKey: url.absoluteString)
    }
}

// MARK: - Supporting Types
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var cacheTime: TimeInterval { get }
    func asURL() -> URL?
}

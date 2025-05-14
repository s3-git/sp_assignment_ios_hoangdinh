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
    private let logger = Logger.shared
    private let errorHandler: ErrorHandlingServiceProtocol

    // MARK: - Initialization
    init(session: URLSession? = .shared, 
         cacheManager: CacheManager = .shared,
         errorHandler: ErrorHandlingServiceProtocol = ErrorHandlingService()) {
        self.baseURL = Environment.shared.baseURL
        self.cacheManager = cacheManager
        self.errorHandler = errorHandler

        // Configure URLSession with caching
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = AppConstants.Network.timeoutInterval

        self.session = session ?? URLSession(configuration: configuration)
    }
    
    // MARK: - Public Methods
    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, AppError> {
        guard let url = endpoint.asURL() else {
            
            return Fail(error: AppError.network(.invalidURL)).eraseToAnyPublisher()
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
            .mapError { error -> AppError in
                
                self.errorHandler.logError(error)
                return AppError.network(.networkError(error))
            }
            .flatMap { data, response -> AnyPublisher<T, AppError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    
                    self.errorHandler.logError(AppError.network(.invalidResponse))
                    return Fail(error: AppError.network(.invalidResponse)).eraseToAnyPublisher()
                }

                // Log response
                self.logger.logResponse(httpResponse, data: data)

                guard (200...299).contains(httpResponse.statusCode) else {
                    
                    let error = AppError.network(.httpError(httpResponse.statusCode))
                    self.errorHandler.logError(error)
                    return Fail(error: error).eraseToAnyPublisher()
                }

                // Cache the successful response
                self.cacheManager.cacheResponse(data, forKey: url.absoluteString, expirationTime: endpoint.cacheTime)
                self.logger.info("Successfully cached response for URL: \(url.absoluteString)")

                return Just(data)
                    .decode(type: T.self, decoder: JSONDecoder())
                    .mapError { error -> AppError in
                        
                        self.errorHandler.logError(error)
                        return AppError.network(.decodingError(error))
                    }
                    .eraseToAnyPublisher()
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
            self.errorHandler.logError(AppError.cache(.cacheClearFailed("Invalid URL for cache removal")))
            return
        }
        logger.info("Removing cache for URL: \(url.absoluteString)")
        cacheManager.removeSpecificCache(forKey: url.absoluteString)
    }
}

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

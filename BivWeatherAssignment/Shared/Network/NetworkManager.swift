import Combine
import Foundation

protocol NetworkManagerProtocol {
    func clearCache()
    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, NetworkError>
    func removeCache(for endpoint: Endpoint)
}

final class NetworkManager: NetworkManagerProtocol {
    // MARK: - Properties
    private let session: URLSession
    private let cacheManager: CacheManagerProtocol
    private let logger: Logger = .shared

    // MARK: - Initialization
    init(session: URLSession? = .shared, 
         cacheManager: CacheManagerProtocol = CacheManager.shared) {
        self.cacheManager = cacheManager

        // Configure URLSession with caching
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = AppConstants.Network.timeoutInterval

        self.session = session ?? URLSession(configuration: configuration)
    }
    
    // MARK: - Public Methods
    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, NetworkError> {
        guard let url = endpoint.asURL() else {
            let error = NetworkError.invalidURL
            logger.error(error.localizedDescription)
            return Fail(error: error).eraseToAnyPublisher()
        }

        // Check cache first
        if let cachedData = cacheManager.getCachedResponse(forKey: url.absoluteString),
           let decodedData = try? JSONDecoder().decode(T.self, from: cachedData), endpoint.cacheTime != 0 {
            logger.info("Cache hit for URL: \(url.absoluteString)")
            return Just(decodedData)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        // Log outgoing request
        logger.logRequest(request)

        return session.dataTaskPublisher(for: request)
            .mapError { [weak self] error -> NetworkError in
                var networkError: NetworkError = NetworkError.custom(error)

                guard let self = self else { return networkError }

                switch error.code {
                    case .timedOut:
                        networkError = .timeout
                    case .secureConnectionFailed:
                        networkError = .sslError(error)
                    default:
                        networkError = .networkError(error)
                }
                self.logger.error(networkError.localizedDescription)
                return networkError
            }
            .flatMap { [weak self] data, response -> AnyPublisher<T, NetworkError> in
                guard let self = self else {
                    return Fail(error: NetworkError.custom(NSError(domain: "", code: -1))).eraseToAnyPublisher()
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    let error = NetworkError.invalidResponse
                    self.logger.error(error.localizedDescription)
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
                        .mapError { error -> NetworkError in
                            let networkError: NetworkError = .decodingError(error)
                            self.logger.error(networkError.localizedDescription)
                            return networkError
                        }
                        .eraseToAnyPublisher()
                        
                case 429:
                    let error = NetworkError.rateLimitExceeded
                    self.logger.error(error.localizedDescription)
                    return Fail(error: error).eraseToAnyPublisher()
                    
                default:
                    let error = NetworkError.httpError(httpResponse.statusCode)
                    self.logger.error(error.localizedDescription)
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
            let error = NetworkError.invalidURL
            logger.error(error.localizedDescription)
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

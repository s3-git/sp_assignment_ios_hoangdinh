import Combine
import Foundation

/// NetworkManager handles all network requests in the application
/// Uses Combine framework for reactive programming and CacheManager for response caching
final class NetworkManager {
    // MARK: - Properties
    private let session: URLSession
    private let baseURL: String
    private let cacheManager: CacheManager

    // MARK: - Initialization
    init(session: URLSession = .shared, cacheManager: CacheManager = .shared) {
        self.baseURL = Environment.shared.baseURL
        self.cacheManager = cacheManager

        // Configure URLSession with caching
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = AppConstants.Network.timeoutInterval

        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Public Methods
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, NetworkError> {
        guard let url = endpoint.asURL() else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        // Check cache first
        if let cachedData = cacheManager.getCachedResponse(forKey: url.absoluteString),
           let decodedData = try? JSONDecoder().decode(T.self, from: cachedData) {
            return Just(decodedData)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers

        return session.dataTaskPublisher(for: request)
            .mapError { NetworkError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<T, NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: NetworkError.httpError(httpResponse.statusCode)).eraseToAnyPublisher()
                }

                // Cache the successful response
                self.cacheManager.cacheResponse(data, forKey: url.absoluteString, expirationTime: endpoint.cacheTime)

                return Just(data)
                    .decode(type: T.self, decoder: JSONDecoder())
                    .mapError { NetworkError.decodingError($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Cache Management
    func clearCache() {
        cacheManager.clearRequestCache()
    }

    func removeCache(for endpoint: Endpoint) {
        guard let url = endpoint.asURL() else { return }
        cacheManager.clearRequestCache()
    }
}

// MARK: - Supporting Types
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case networkError(Error)
    case decodingError(Error)
    case custom(Error)
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

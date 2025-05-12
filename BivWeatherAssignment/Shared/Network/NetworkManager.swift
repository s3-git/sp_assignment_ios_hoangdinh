import Foundation
import Combine

/// NetworkManager handles all network requests in the application
/// Uses Combine framework for reactive programming and URLCache for response caching
final class NetworkManager {
    // MARK: - Properties
    private let session: URLSession
    private let baseURL: String
    
    // MARK: - Initialization
    init(session: URLSession = .shared) {
        self.baseURL = AppConstants.Network.baseURL
        
        // Configure URLSession with caching
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.timeoutIntervalForRequest = AppConstants.Network.timeoutInterval
        
        // Configure URLCache
        let cache = URLCache(
            memoryCapacity: AppConstants.Network.memoryCacheSize,
            diskCapacity: AppConstants.Network.diskCacheSize,
            directory: nil
        )
        configuration.urlCache = cache
        
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Public Methods
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, NetworkError> {
        guard let url = URL(string: baseURL + endpoint.path) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        // Set cache policy for this specific request
        request.cachePolicy = .returnCacheDataElseLoad
        
        return session.dataTaskPublisher(for: request)
            .mapError { NetworkError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<T, NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: NetworkError.httpError(httpResponse.statusCode)).eraseToAnyPublisher()
                }
                
                return Just(data)
                    .decode(type: T.self, decoder: JSONDecoder())
                    .mapError { NetworkError.decodingError($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Cache Management
    func clearCache() {
        session.configuration.urlCache?.removeAllCachedResponses()
    }
    
    func removeCache(for endpoint: Endpoint) {
        guard let url = URL(string: baseURL + endpoint.path) else { return }
        session.configuration.urlCache?.removeCachedResponse(for: URLRequest(url: url))
    }
}

// MARK: - Supporting Types
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case networkError(Error)
    case decodingError(Error)
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
} 

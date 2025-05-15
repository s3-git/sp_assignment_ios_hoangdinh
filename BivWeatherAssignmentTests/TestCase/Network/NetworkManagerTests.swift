@testable import BivWeatherAssignment
import Combine
import XCTest

final class NetworkManagerTests: BaseXCTestCase {
    // MARK: - Properties
    private var sut: NetworkManagerProtocol!
    private var mockNetworkManager: NetworkManagerProtocol!
    private var mockCacheManager: CacheManagerProtocol!
    
    // MARK: - Test Setup
    override func setUp() {
        super.setUp()
        mockCacheManager = MockCacheManager()
        
        sut = NetworkManager(
            session: .shared,
            cacheManager: mockCacheManager,
            logger: Logger.shared,
            errorHandler: ErrorHandlingService()
        )
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkManager = nil
        mockCacheManager = nil
        super.tearDown()
    }
    
}

// MARK: - Mock Types
private struct MockEndpoint: Endpoint {
    var path: String = "test"
    var method: HTTPMethod = .get
    var headers: [String: String] = [:]
    var cacheTime: TimeInterval = 300
    
    func asURL() -> URL? {
        return URL(string: "https://test.com")
    }
} 

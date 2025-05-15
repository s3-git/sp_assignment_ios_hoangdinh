@testable import BivWeatherAssignment
import Combine
import XCTest

final class NetworkManagerTests: XCTestCase {
    // MARK: - Properties
    private var sut: NetworkManager!
    private var mockSession: MockURLSession!
    private var mockCacheManager: MockCacheManager!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Test Lifecycle
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        mockCacheManager = MockCacheManager()
        sut = NetworkManager(session: mockSession, cacheManager: mockCacheManager)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockSession = nil
        mockCacheManager = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func testRequestSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Network request succeeds")
        let mockData = MockResponse(id: 1, name: "Test")
        let mockEndpoint = MockEndpoint(path: "test", method: .get)
        
        mockSession.mockData = try? JSONEncoder().encode(mockData)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        sut.request(mockEndpoint)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Request should succeed")
                    }
                    expectation.fulfill()
                },
                receiveValue: { (response: MockResponse) in
                    // Then
                    XCTAssertEqual(response.id, mockData.id)
                    XCTAssertEqual(response.name, mockData.name)
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRequestWithCache() {
        // Given
        let expectation = XCTestExpectation(description: "Cache hit")
        let mockEndpoint = MockEndpoint(path: "test", method: .get, cacheTime: 300)
        let mockResponse = MockResponse(id: 1, name: "Test")
        
        guard let url = mockEndpoint.asURL(),
              let mockData = try? JSONEncoder().encode(mockResponse) else {
            XCTFail("Failed to create mock data")
            return
        }
        
        mockCacheManager.setMockCache(mockData, forKey: url.absoluteString, expirationTime: mockEndpoint.cacheTime)
        
        // When
        sut.request(mockEndpoint)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Request should succeed")
                    }
                    expectation.fulfill()
                },
                receiveValue: { (response: MockResponse) in
                    // Then
                    XCTAssertEqual(response.id, mockResponse.id)
                    XCTAssertEqual(response.name, mockResponse.name)
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRequestTimeout() {
        // Given
        let expectation = XCTestExpectation(description: "Request times out")
        let mockEndpoint = MockEndpoint(path: "test", method: .get)
        
        mockSession.mockError = URLError(.timedOut)
        
        // When
        sut.request(mockEndpoint)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // Then
                        XCTAssertEqual(error, .timeout)
                        expectation.fulfill()
                    }
                },
                receiveValue: { (_: MockResponse) in
                    XCTFail("Request should fail")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRequestSSLError() {
        // Given
        let expectation = XCTestExpectation(description: "SSL error")
        let mockEndpoint = MockEndpoint(path: "test", method: .get)
        
        mockSession.mockError = URLError(.secureConnectionFailed)
        
        // When
        sut.request(mockEndpoint)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // Then
                        if case .sslError = error {
                            expectation.fulfill()
                        } else {
                            XCTFail("Expected SSL error")
                        }
                    }
                },
                receiveValue: { (_: MockResponse) in
                    XCTFail("Request should fail")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRequestRateLimit() {
        // Given
        let expectation = XCTestExpectation(description: "Rate limit exceeded")
        let mockEndpoint = MockEndpoint(path: "test", method: .get)
        
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 429,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        sut.request(mockEndpoint)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // Then
                        XCTAssertEqual(error, .rateLimitExceeded)
                        expectation.fulfill()
                    }
                },
                receiveValue: { (_: MockResponse) in
                    XCTFail("Request should fail")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRequestDecodingError() {
        // Given
        let expectation = XCTestExpectation(description: "Decoding error")
        let mockEndpoint = MockEndpoint(path: "test", method: .get)
        
        mockSession.mockData = "invalid json".data(using: .utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        sut.request(mockEndpoint)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // Then
                        if case .decodingError = error {
                            expectation.fulfill()
                        } else {
                            XCTFail("Expected decoding error")
                        }
                    }
                },
                receiveValue: { (_: MockResponse) in
                    XCTFail("Request should fail")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testClearCache() {
        // Given
        let mockEndpoint = MockEndpoint(path: "test", method: .get)
        guard let url = mockEndpoint.asURL() else {
            XCTFail("Failed to create URL")
            return
        }
        
        // Add some test data to cache
        let mockData = "test data".data(using: .utf8)!
        mockCacheManager.setMockCache(mockData, forKey: url.absoluteString, expirationTime: 300)
        
        // When
        sut.clearCache()
        
        // Then
        XCTAssertNil(mockCacheManager.getCachedResponse(forKey: url.absoluteString))
    }
    
    func testRemoveSpecificCache() {
        // Given
        let mockEndpoint = MockEndpoint(path: "test", method: .get)
        guard let url = mockEndpoint.asURL() else {
            XCTFail("Failed to create URL")
            return
        }
        
        // Add test data to cache
        let mockData = "test data".data(using: .utf8)!
        mockCacheManager.setMockCache(mockData, forKey: url.absoluteString, expirationTime: 300)
        
        // When
        sut.removeCache(for: mockEndpoint)
        
        // Then
        XCTAssertNil(mockCacheManager.getCachedResponse(forKey: url.absoluteString))
    }
    
}

// MARK: - Mock Types
private struct MockResponse: Codable {
    let id: Int
    let name: String
}

private struct MockEndpoint: Endpoint {
    let path: String
    let method: HTTPMethod
    var headers: [String: String] = [:]
    var cacheTime: TimeInterval = 0
    
    func asURL() -> URL? {
        return URL(string: "https://test.com/\(path)")
    }
}

private class MockURLSession: URLSession {
    var mockData: Data?
    var mockResponse: HTTPURLResponse?
    var mockError: Error?
    
    override func dataTask(with _: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let data = self.mockData
        let response = self.mockResponse
        let error = self.mockError
        return SessionDataTaskMock {
            completionHandler(data, response, error)
        }
    }
    
    override func dataTask(with _: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let data = self.mockData
        let response = self.mockResponse
        let error = self.mockError
        return SessionDataTaskMock {
            completionHandler(data, response, error)
        }
    }
    class SessionDataTaskMock: URLSessionDataTask {
        private let closure: () -> Void
        
        init(closure: @escaping () -> Void) {
            self.closure = closure
        }
        
        override func resume() {
            closure()
        }
        
        override func cancel() {
            closure()
        }
    }
}

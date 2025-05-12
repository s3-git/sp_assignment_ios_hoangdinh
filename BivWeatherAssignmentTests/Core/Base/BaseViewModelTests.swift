import XCTest
import Combine

/// Base test class for ViewModel testing
class BaseViewModelTests: XCTestCase {
    // MARK: - Properties
    var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    func waitForPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output where T.Failure == Never {
        let expectation = expectation(description: "Publisher expectation")
        var result: T.Output?
        
        publisher
            .sink { value in
                result = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: timeout)
        
        guard let output = result else {
            XCTFail("Publisher did not emit any value", file: file, line: line)
            throw NSError(domain: "BaseViewModelTests", code: -1)
        }
        
        return output
    }
} 

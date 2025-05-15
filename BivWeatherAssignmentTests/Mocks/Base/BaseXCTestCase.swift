import Combine
import XCTest

class BaseXCTestCase: XCTestCase {
    // MARK: - Properties
    var cancellables: Set<AnyCancellable>!
    
    let networkHelper = NetworkTestHelper.shared

    // MARK: - Setup
    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
}

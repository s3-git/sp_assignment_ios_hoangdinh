import Combine
import XCTest

/// Base test class for XCTestCase testing
class BaseXCTestCase: XCTestCase {
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

    // MARK: - UserDefaults Helpers
    /// Creates a test UserDefaults instance that won't affect the real UserDefaults
    /// - Returns: A new UserDefaults instance for testing
    func createTestUserDefaults() -> UserDefaults {
        let testDefaults = UserDefaults(suiteName: #file)!
        testDefaults.removePersistentDomain(forName: #file)
        return testDefaults
    }
    
    /// Cleans up a test UserDefaults instance
    /// - Parameter defaults: The UserDefaults instance to clean up
    func cleanupTestUserDefaults(_ defaults: UserDefaults) {
        defaults.removePersistentDomain(forName: #file)
    }

    // MARK: - Array Testing Helpers
    /// Verifies that an array contains elements in the expected order
    /// - Parameters:
    ///   - array: The array to verify
    ///   - expectedElements: The expected elements in order
    ///   - file: The file where the test is located
    ///   - line: The line where the test is located
    func assertArrayOrder<T: Equatable>(
        _ array: [T],
        equals expectedElements: [T],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(array.count, expectedElements.count, "Array count mismatch", file: file, line: line)
        for (index, element) in array.enumerated() {
            XCTAssertEqual(element, expectedElements[index], "Element at index \(index) does not match", file: file, line: line)
        }
    }
    
    /// Verifies that an array contains exactly the expected elements, regardless of order
    /// - Parameters:
    ///   - array: The array to verify
    ///   - expectedElements: The expected elements
    ///   - file: The file where the test is located
    ///   - line: The line where the test is located
    func assertArrayContainsExactly<T: Equatable>(
        _ array: [T],
        expectedElements: [T],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(array.count, expectedElements.count, "Array count mismatch", file: file, line: line)
        for element in expectedElements {
            XCTAssertTrue(array.contains(element), "Array does not contain expected element: \(element)", file: file, line: line)
        }
    }

    // MARK: - Publisher Helper Methods
    
    /// Waits for a publisher to emit a value and returns it
    /// - Parameters:
    ///   - publisher: The publisher to wait for
    ///   - timeout: The maximum time to wait
    ///   - file: The file where the test is located
    ///   - line: The line where the test is located
    /// - Returns: The emitted value
    /// - Throws: An error if no value is emitted or if the publisher fails
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
    
    /// Waits for a publisher to complete and returns its completion state
    /// - Parameters:
    ///   - publisher: The publisher to wait for
    ///   - timeout: The maximum time to wait
    ///   - file: The file where the test is located
    ///   - line: The line where the test is located
    /// - Returns: The completion state of the publisher
    func waitForCompletion<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Subscribers.Completion<T.Failure> {
        let expectation = expectation(description: "Publisher completion expectation")
        var completion: Subscribers.Completion<T.Failure>?
        
        publisher
            .sink(receiveCompletion: { comp in
                completion = comp
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: timeout)
        
        guard let result = completion else {
            XCTFail("Publisher did not complete", file: file, line: line)
            return .finished
        }
        
        return result
    }
    
    /// Waits for a publisher to emit a value and verifies it matches the expected value
    /// - Parameters:
    ///   - publisher: The publisher to wait for
    ///   - expectedValue: The expected value
    ///   - timeout: The maximum time to wait
    ///   - file: The file where the test is located
    ///   - line: The line where the test is located
    func expectPublisherValue<T: Publisher>(
        _ publisher: T,
        toEqual expectedValue: T.Output,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) where T.Failure == Never, T.Output: Equatable {
        let expectation = expectation(description: "Publisher value expectation")
        
        publisher
            .sink { value in
                XCTAssertEqual(value, expectedValue, file: file, line: line)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: timeout)
    }
    
    /// Waits for a publisher to fail with a specific error
    /// - Parameters:
    ///   - publisher: The publisher to wait for
    ///   - expectedError: The expected error
    ///   - timeout: The maximum time to wait
    ///   - file: The file where the test is located
    ///   - line: The line where the test is located
    func expectPublisherFailure<T: Publisher>(
        _ publisher: T,
        toFailWith expectedError: T.Failure,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) where T.Failure: Equatable {
        let expectation = expectation(description: "Publisher failure expectation")
        
        publisher
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error, expectedError, file: file, line: line)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Publisher should fail", file: file, line: line)
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: timeout)
    }
    
    // MARK: - Async Helper Methods
    
    /// Waits for an async operation to complete
    /// - Parameters:
    ///   - timeout: The maximum time to wait
    ///   - file: The file where the test is located
    ///   - line: The line where the test is located
    ///   - operation: The async operation to wait for
    func waitForAsync(
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line,
        operation: @escaping () async throws -> Void
    ) {
        let expectation = expectation(description: "Async operation expectation")
        
        Task {
            do {
                try await operation()
                expectation.fulfill()
            } catch {
                XCTFail("Async operation failed with error: \(error)", file: file, line: line)
            }
        }
        
        wait(for: [expectation], timeout: timeout)
    }
    
    /// Waits for an async operation to complete and returns its result
    /// - Parameters:
    ///   - timeout: The maximum time to wait
    ///   - file: The file where the test is located
    ///   - line: The line where the test is located
    ///   - operation: The async operation to wait for
    /// - Returns: The result of the async operation
    func waitForAsyncResult<T>(
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line,
        operation: @escaping () async throws -> T
    ) -> T? {
        let expectation = expectation(description: "Async operation expectation")
        var result: T?
        
        Task {
            do {
                result = try await operation()
                expectation.fulfill()
            } catch {
                XCTFail("Async operation failed with error: \(error)", file: file, line: line)
            }
        }
        
        wait(for: [expectation], timeout: timeout)
        return result
    }
    
    // MARK: - Common Testing Patterns
    
    /// Verifies that a publisher emits values in the expected order
    /// - Parameters:
    ///   - publisher: The publisher to verify
    ///   - expectedValues: The expected values in order
    ///   - timeout: The maximum time to wait
    ///   - file: The file where the test is located
    ///   - line: The line where the test is located
    func verifyPublisherSequence<T: Publisher>(
        _ publisher: T,
        emits expectedValues: [T.Output],
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) where T.Failure == Never, T.Output: Equatable {
        let expectation = expectation(description: "Publisher sequence expectation")
        var receivedValues: [T.Output] = []
        
        publisher
            .sink { value in
                receivedValues.append(value)
                if receivedValues.count == expectedValues.count {
                    XCTAssertEqual(receivedValues, expectedValues, file: file, line: line)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: timeout)
    }
    
    /// Verifies that a publisher completes without emitting any values
    /// - Parameters:
    ///   - publisher: The publisher to verify
    ///   - timeout: The maximum time to wait
    ///   - file: The file where the test is located
    ///   - line: The line where the test is located
    func verifyPublisherCompletesWithoutEmitting<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) where T.Failure == Never {
        let expectation = expectation(description: "Publisher completion expectation")
        
        publisher
            .sink(receiveCompletion: { completion in
                if case .finished = completion {
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Publisher should not emit any values", file: file, line: line)
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: timeout)
    }

    // MARK: - Service Testing Helpers
    
    /// Verifies that a service method maintains a maximum limit
    /// - Parameters:
    ///   - addItem: Closure that adds an item to the service
    ///   - getItems: Closure that retrieves items from the service
    ///   - maxLimit: The maximum number of items allowed
    ///   - file: The file where the test is located
    ///   - line: The line where the test is located
    func assertMaintainsMaxLimit<T>(
        addItem: (T) -> Void,
        getItems: () -> [T],
        maxLimit: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        // Add more items than the limit
        for i in 0..<maxLimit + 5 {
            addItem(T.self as! T)
        }
        
        let items = getItems()
        XCTAssertEqual(items.count, maxLimit, "Service did not maintain maximum limit", file: file, line: line)
    }
    
    /// Verifies that a service method handles duplicates correctly
    /// - Parameters:
    ///   - addItem: Closure that adds an item to the service
    ///   - getItems: Closure that retrieves items from the service
    ///   - item: The item to add
    ///   - file: The file where the test is located
    ///   - line: The line where the test is located
    func assertHandlesDuplicates<T: Equatable>(
        addItem: (T) -> Void,
        getItems: () -> [T],
        item: T,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        addItem(item)
        addItem(item)
        
        let items = getItems()
        XCTAssertEqual(items.count, 1, "Service did not handle duplicates correctly", file: file, line: line)
        XCTAssertEqual(items.first, item, "Service did not maintain the correct item", file: file, line: line)
    }
    
    /// Verifies that a service method maintains order (most recent first)
    /// - Parameters:
    ///   - addItems: Closure that adds items to the service
    ///   - getItems: Closure that retrieves items from the service
    ///   - items: The items to add in order
    ///   - file: The file where the test is located
    ///   - line: The line where the test is located
    func assertMaintainsOrder<T: Equatable>(
        addItems: ([T]) -> Void,
        getItems: () -> [T],
        items: [T],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        addItems(items)
        
        let result = getItems()
        assertArrayOrder(result, equals: items.reversed(), file: file, line: line)
    }
    
    /// Verifies that a service method handles nil values gracefully
    /// - Parameters:
    ///   - addItem: Closure that adds an item to the service
    ///   - getItems: Closure that retrieves items from the service
    ///   - nilItem: The nil item to add
    ///   - file: The file where the test is located
    ///   - line: The line where the test is located
    func assertHandlesNilValues<T>(
        addItem: (T?) -> Void,
        getItems: () -> [T],
        nilItem: T?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        addItem(nilItem)
        
        let items = getItems()
        XCTAssertEqual(items.count, 1, "Service did not handle nil values correctly", file: file, line: line)
    }
    
    /// Verifies that a service method handles empty collections gracefully
    /// - Parameters:
    ///   - addItem: Closure that adds an item to the service
    ///   - getItems: Closure that retrieves items from the service
    ///   - emptyItem: The empty item to add
    ///   - file: The file where the test is located
    ///   - line: The line where the test is located
    func assertHandlesEmptyCollections<T>(
        addItem: (T) -> Void,
        getItems: () -> [T],
        emptyItem: T,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        addItem(emptyItem)
        
        let items = getItems()
        XCTAssertEqual(items.count, 1, "Service did not handle empty collections correctly", file: file, line: line)
    }
    
    /// Verifies that a service method handles non-existent items gracefully
    /// - Parameters:
    ///   - addItem: Closure that adds an item to the service
    ///   - removeItem: Closure that removes an item from the service
    ///   - getItems: Closure that retrieves items from the service
    ///   - existingItem: An item that exists in the service
    ///   - nonExistentItem: An item that doesn't exist in the service
    ///   - file: The file where the test is located
    ///   - line: The line where the test is located
    func assertHandlesNonExistentItems<T: Equatable>(
        addItem: (T) -> Void,
        removeItem: (T) -> Void,
        getItems: () -> [T],
        existingItem: T,
        nonExistentItem: T,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        addItem(existingItem)
        removeItem(nonExistentItem)
        
        let items = getItems()
        XCTAssertEqual(items.count, 1, "Service did not handle non-existent items correctly", file: file, line: line)
        XCTAssertEqual(items.first, existingItem, "Service did not maintain the correct item", file: file, line: line)
    }
}

@testable import BivWeatherAssignment
import Combine
import XCTest

final class CombineExtensionsTests: BaseXCTestCase {
    
    // MARK: - Test Classes
    private class TestObject {
        var value: Int = 0
        var completionCalled = false
        var error: Error?
    }
    
    // MARK: - Publisher Extensions Tests
    func testSinkWithWeakReference() {
        // Given
        let expectation = XCTestExpectation(description: "Value received")
        let subject = CurrentValueSubject<Int, Never>(0)
        let testObject = TestObject()
        
        // When
        subject
            .sink(weak: testObject) { object, value in
                object.value = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        subject.send(42)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(testObject.value, 42)
    }
    
    func testSinkWithWeakReferenceAndCompletion() {
        // Given
        let expectation = XCTestExpectation(description: "Completion received")
        let subject = PassthroughSubject<Int, TestError>()
        let testObject = TestObject()
        
        // When
        subject
            .sink(
                weak: testObject,
                receiveValue: { object, value in
                    object.value = value
                },
                receiveCompletion: { object, completion in
                    if case .failure(let error) = completion {
                        object.error = error
                    }
                    object.completionCalled = true
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        subject.send(42)
        subject.send(completion: .failure(.testError))
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(testObject.value, 42)
        XCTAssertTrue(testObject.completionCalled)
        XCTAssertEqual(testObject.error as? TestError, .testError)
    }
    
    // MARK: - CurrentValueSubject Extensions Tests
    func testUpdateIfNeeded() {
        // Given
        let subject = CurrentValueSubject<Int, Never>(0)
        var receivedValues: [Int] = []
        
        // When
        subject
            .sink { value in
                receivedValues.append(value)
            }
            .store(in: &cancellables)
        
        subject.updateIfNeeded(1) // Should update
        subject.updateIfNeeded(1) // Should not update
        subject.updateIfNeeded(2) // Should update
        
        // Then
        XCTAssertEqual(receivedValues, [0, 1, 2])
    }
    
    // MARK: - PassthroughSubject Extensions Tests
    func testSendIfNotNil() {
        // Given
        let subject = PassthroughSubject<Int?, Never>()
        var receivedValues: [Int] = []
        
        // When
        subject
            .compactMap { $0 }
            .sink { value in
                receivedValues.append(value)
            }
            .store(in: &cancellables)
        
        subject.sendIfNotNil(1)
        subject.sendIfNotNil(nil)
        subject.sendIfNotNil(2)
        
        // Then
        XCTAssertEqual(receivedValues, [1, 2])
    }
}

// MARK: - Test Error
private enum TestError: Error, Equatable {
    case testError
} 

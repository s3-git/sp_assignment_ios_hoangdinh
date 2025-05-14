import Foundation

/// Base protocol for all mock objects
public protocol MockProtocol {
    /// Reset the mock to its initial state
    func reset()
}

/// Default implementation of reset
public extension MockProtocol {
    func reset() {
        // Default implementation does nothing
    }
} 

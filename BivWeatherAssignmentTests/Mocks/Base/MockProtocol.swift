import Foundation

public protocol MockProtocol {
    func reset()
}

public extension MockProtocol {
    func reset() {
        // Default implementation does nothing
    }
} 

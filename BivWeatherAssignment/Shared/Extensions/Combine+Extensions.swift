import Combine
import Foundation

// MARK: - Publisher Extensions
extension Publisher where Failure == Never {
    /// Sink with weak reference to avoid retain cycles
    func sink<Root: AnyObject>(
        weak object: Root,
        receiveValue: @escaping (Root, Output) -> Void
    ) -> AnyCancellable {
        sink { [weak object] output in
            guard let object = object else { return }
            receiveValue(object, output)
        }
    }
}

extension Publisher {
    /// Sink with weak reference and completion handler
    func sink<Root: AnyObject>(
        weak object: Root,
        receiveValue: @escaping (Root, Output) -> Void,
        receiveCompletion: @escaping (Root, Subscribers.Completion<Failure>) -> Void
    ) -> AnyCancellable {
        sink(
            receiveCompletion: { [weak object] completion in
                guard let object = object else { return }
                receiveCompletion(object, completion)
            },
            receiveValue: { [weak object] output in
                guard let object = object else { return }
                receiveValue(object, output)
            }
        )
    }

    /// Convert to async/await
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = self
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                        cancellable?.cancel()
                    }
                )
        }
    }
}

// MARK: - AnyCancellable Extensions
extension AnyCancellable {
    /// Store in a set of cancellables
    func store(in set: inout Set<AnyCancellable>) {
        set.insert(self)
    }
}

// MARK: - CurrentValueSubject Extensions
extension CurrentValueSubject where Output: Equatable {
    /// Update value if different
    func updateIfNeeded(_ newValue: Output) {
        if value != newValue {
            send(newValue)
        }
    }
}

// MARK: - PassthroughSubject Extensions
extension PassthroughSubject {
    /// Send value if not nil
    func sendIfNotNil(_ value: Output?) {
        if let value = value {
            send(value)
        }
    }
}

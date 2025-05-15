import Combine
import Foundation

// MARK: - Publisher Extensions
extension Publisher where Failure == Never {
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
}

// MARK: - CurrentValueSubject Extensions
extension CurrentValueSubject where Output: Equatable {
    func updateIfNeeded(_ newValue: Output) {
        if value != newValue {
            send(newValue)
        }
    }
}

// MARK: - PassthroughSubject Extensions
extension PassthroughSubject {
    func sendIfNotNil(_ value: Output?) {
        if let value = value {
            send(value)
        }
    }
}

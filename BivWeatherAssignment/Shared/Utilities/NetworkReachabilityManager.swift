import Foundation
import Network
import Combine

/// Manager for monitoring network connectivity
class NetworkReachabilityManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .unknown

    // MARK: - Properties
    static let shared = NetworkReachabilityManager()
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkReachability")

    // MARK: - Types
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    // MARK: - Initialization
    private init() {
        monitor = NWPathMonitor()
        setupMonitoring()
    }

    // MARK: - Private Methods
    private func setupMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = self?.getConnectionType(path) ?? .unknown
            }
        }
        monitor.start(queue: queue)
    }

    private func getConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
    }

    // MARK: - Public Methods
    /// Check if network is available
    var isNetworkAvailable: Bool {
        isConnected
    }

    /// Get current connection type
    var currentConnectionType: ConnectionType {
        connectionType
    }

    /// Stop monitoring
    func stopMonitoring() {
        monitor.cancel()
    }

    // MARK: - Deinitialization
    deinit {
        stopMonitoring()
    }
}

// MARK: - Publisher Extension
extension NetworkReachabilityManager {
    /// Publisher for network status changes
    var networkStatusPublisher: AnyPublisher<Bool, Never> {
        $isConnected
            .eraseToAnyPublisher()
    }

    /// Publisher for connection type changes
    var connectionTypePublisher: AnyPublisher<ConnectionType, Never> {
        $connectionType
            .eraseToAnyPublisher()
    }
}

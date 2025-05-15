import Foundation
import OSLog

class Logger {
    // MARK: - Properties
    static let shared = Logger()
    private let logger: OSLog

    // MARK: - Log Levels
    enum Level: String {
        case debug = "🔍"
        case info = "ℹ️"
        case warning = "⚠️"
        case error = "❌"
        case critical = "💥"
    }

    // MARK: - Initialization
    private init() {
        logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.bivweather", category: "App")
    }

    // MARK: - Public Methods
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }

    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }

    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }

    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }

    func critical(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .critical, file: file, function: function, line: line)
    }

    // MARK: - Private Methods
    private func log(_ message: String, level: Level, file: String, function: String, line: Int) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(level.rawValue) [\(fileName):\(line)] \(function): \(message)"

//        #if DEBUG
//        print(logMessage)
//        #endif

        os_log("%{public}@", log: logger, type: level.osLogType, logMessage)
    }
}

// MARK: - Level Extension
extension Logger.Level {
    var osLogType: OSLogType {
        switch self {
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .default
        case .error:
            return .error
        case .critical:
            return .fault
        }
    }
}

// MARK: - Convenience Methods
extension Logger {
    func logRequest(_ request: URLRequest) {
        debug("""
        🌐 Request:
        URL: \(request.url?.absoluteString ?? "nil")
        Method: \(request.httpMethod ?? "nil")
        Headers: \(request.allHTTPHeaderFields ?? [:])
        Body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "nil")
        """)
    }

    func logResponse(_ response: HTTPURLResponse, data: Data?) {
        debug("""
        📥 Response:
        Status Code: \(response.statusCode)
        Headers: \(response.allHeaderFields)
        Body: \(String(data: data ?? Data(), encoding: .utf8) ?? "nil")
        """)
    }

    func logError(_ error: Error) {
        self.error("""
        Error: \(error.localizedDescription)
        Code: \((error as NSError).code)
        Domain: \((error as NSError).domain)
        User Info: \((error as NSError).userInfo)
        """)
    }
}

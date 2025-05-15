import Foundation

/// Environment configuration manager
protocol EnvironmentProtocol {
    var apiKey: String { get }
    var baseURL: String { get }
}
final class Environment: EnvironmentProtocol {
    // MARK: - Singleton
    static let shared = Environment()

    // MARK: - Properties
    private let plistName :String
    private var environmentDict: [String: Any]?
    private let bundle: Bundle

    // MARK: - API Configuration
    var apiKey: String {
        getValue(for: "API_KEY") ?? ""
    }

    var baseURL: String {
        getValue(for: "BASE_URL") ?? "https://api.worldweatheronline.com/premium/v1"
    }

    // MARK: - Initialization
    init(bundle: Bundle = .main,plistName:String = "Enviroment") {
        self.bundle = bundle
        self.plistName = plistName
        self.loadPlist()
    }

    // MARK: - Private Methods
    private func loadPlist() {
        guard let path = bundle.path(forResource: plistName, ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            Logger.shared.error("Failed to load \(plistName).plist")
            return
        }
        environmentDict = dict
    }

    private func getValue(for key: String) -> String? {
        return environmentDict?[key] as? String
    }
}

import Foundation

/// Environment configuration manager

final class Environment {
    // MARK: - Singleton
    static let shared = Environment()
    
    // MARK: - Properties
    private let plistName = "Environment"
    private var environmentDict: [String: Any]?
    
    // MARK: - API Configuration
    var apiKey: String {
        getValue(for: "API_KEY") ?? ""
    }
    
    var baseURL: String {
        getValue(for: "BASE_URL") ?? "https://api.worldweatheronline.com/premium/v1"
    }
    
    // MARK: - Initialization
    private init() {
        loadPlist()
    }
    
    // MARK: - Private Methods
    private func loadPlist() {
        guard let path = Bundle.main.path(forResource: plistName, ofType: "plist"),
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

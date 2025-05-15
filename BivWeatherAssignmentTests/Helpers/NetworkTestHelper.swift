import Foundation

/// Helper class for network testing
final class NetworkTestHelper {
    // MARK: - Properties
    static let shared = NetworkTestHelper()
    
    // MARK: - Mock Data
    private func getMockDataFromFile(fileName: String) -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: fileName, withExtension: "json") else {
            fatalError("Failed to find \(fileName).json in test bundle")
        }
        
        do {
            return try Data(contentsOf: url)
        } catch {
            fatalError("Failed to load \(fileName).json: \(error.localizedDescription)")
        }
    }
    
    func createMockWeatherResponse() -> Data {
        let fileName = "getWeatherMockJsonResponse"
        return getMockDataFromFile(fileName: fileName)
    }
    
    func createMockSearchResponse() -> Data {
        let fileName = "searchMockJsonResponse"
        return getMockDataFromFile(fileName: fileName)
    }
    
    func createEmptySearchResponse() -> Data {
        let json = """
        {
            "search_api": {
                "result": []
            }
        }
        """
        return json.data(using: .utf8)!
    }
    
    func createNilSearchResponse() -> Data {
        let json = """
        {
            "search_api": {
            }
        }
        """
        return json.data(using: .utf8)!
    }
    
    func createNilWeatherResponse() -> Data {
        let json = """
        {
            "data": {
            }
        }
        """
        return json.data(using: .utf8)!

    }
    func createEmptyWeatherResponse() -> Data {
        let json = """
        {
            "data": {
                "request": [],
                "request": [],
                "request": [],
                "request": [],
                "request": [],
            }
        }
        """
        return json.data(using: .utf8)!
        
    }
    
}

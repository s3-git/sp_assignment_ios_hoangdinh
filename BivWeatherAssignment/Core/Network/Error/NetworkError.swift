//
//  NetworkError.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/15/25.
//

enum NetworkError: Error, Equatable {
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
    
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case networkError(Error)
    case decodingError(Error)
    case custom(Error)
    case timeout
    case sslError(Error)
    case rateLimitExceeded
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .custom(let error):
            return "Custom error: \(error.localizedDescription)"
        case .timeout:
            return "Request timed out. Please try again"
        case .sslError(let error):
            return "SSL error: \(error.localizedDescription)"
        case .rateLimitExceeded:
            return "Too many requests. Please try again later"
        }
    }
}

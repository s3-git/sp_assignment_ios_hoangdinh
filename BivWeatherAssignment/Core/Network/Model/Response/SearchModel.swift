//
//  SearchResponse.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/12/25.
//
import Foundation

// MARK: - SearchResponse
struct SearchModel: Codable {
    let searchAPI: SearchAPI?

    enum CodingKeys: String, CodingKey {
        case searchAPI = "search_api"
    }
}

// MARK: - SearchAPI
struct SearchAPI: Codable {
    let result: [SearchResult]?
}

// MARK: - Result
struct SearchResult: Codable, Equatable {
    let areaName, country, region: [AreaName]?
    let latitude, longitude, population: String?
    let weatherURL: [AreaName]?

    enum CodingKeys: String, CodingKey {
        case areaName, country, region, latitude, longitude, population
        case weatherURL = "weatherUrl"
    }
}

// MARK: - AreaName
struct AreaName: Codable, Equatable {
    let value: String?
}

//
//  WeatherSearchRequestParameters.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/12/25.
//

import Foundation

struct WeatherSearchRequestParameters {
    var query: String                // Location string, lat,lng, or IP
    var numOfResults: Int?       // Optional number of results

    func toQueryItems() -> [URLQueryItem] {
        
        var items: [URLQueryItem] = [
            URLQueryItem(name: "q", value: query)
        ]

        if let numOfResults = numOfResults {
            items.append(URLQueryItem(name: "num_of_results", value: "\(numOfResults)"))
        }

        return items
    }
}

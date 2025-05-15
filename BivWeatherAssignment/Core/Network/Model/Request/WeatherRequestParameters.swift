//
//  WeatherRequestParameters.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/12/25.
//

import CoreLocation
import Foundation

struct WeatherRequestParameters {
    var query: String                // e.g. "New York", "48.8566,2.3522"
    var numOfDays: Int = 7

    func toQueryItems() -> [URLQueryItem] {
        return [
            .init(name: "q", value: query),
            .init(name: "num_of_days", value: "\(numOfDays)")
        ]
        
    }
}

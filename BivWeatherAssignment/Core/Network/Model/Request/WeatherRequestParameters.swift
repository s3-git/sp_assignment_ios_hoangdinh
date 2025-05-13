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
    var numOfDays: Int = 1
    var date: String?            // "yyyy-MM-dd"
    var fx: String?              // "yes" or "no"
    var mca: String?             // "yes" or "no"
    var fx24: String?            // "yes" or "no"
    var tp: Int?                 // Time interval (e.g., 3, 6, 12)
    var showLocalTime: Bool = true
    var includeLocation: Bool = true

    func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = [
            .init(name: "q", value: query),
            .init(name: "num_of_days", value: "\(numOfDays)"),
            .init(name: "showlocaltime", value: showLocalTime ? "yes" : "no"),
            .init(name: "includelocation", value: includeLocation ? "yes" : "no")
        ]

        if let date = date {
            items.append(.init(name: "date", value: date))
        }
        if let fx = fx {
            items.append(.init(name: "fx", value: fx))
        }
        if let mca = mca {
            items.append(.init(name: "mca", value: mca))
        }
        if let fx24 = fx24 {
            items.append(.init(name: "fx24", value: fx24))
        }
        if let tp = tp {
            items.append(.init(name: "tp", value: "\(tp)"))
        }

        return items
    }
}

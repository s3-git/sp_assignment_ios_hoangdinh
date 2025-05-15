//
//  Int+Extensions.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/15/25.
//

extension Double {
    func formatPopulation() -> String {
        let number = self
        let thousand = number / 1000
        let million = number / 1000000
        let billion = number / 1000000000
        
        if billion >= 1.0 {
            return String(format: "%.1fB", billion)
        } else if million >= 1.0 {
            return String(format: "%.1fM", million)
        } else if thousand >= 1.0 {
            return String(format: "%.1fK", thousand)
        } else {
            return String(self)
        }
    }
}

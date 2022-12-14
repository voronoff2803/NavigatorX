//
//  Date+add.swift
//  VPN 2
//
//  Created by Alexey Voronov on 05/08/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import Foundation

extension Date {
    
    /// Returns a Date with the specified amount of components added to the one it is called with
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        let components = DateComponents(year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds)
        return Calendar.current.date(byAdding: components, to: self)
    }
    
    /// Returns a Date with the specified amount of components subtracted from the one it is called with
    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        return add(years: -years, months: -months, days: -days, hours: -hours, minutes: -minutes, seconds: -seconds)
    }
    
    func dateAndTimetoString(format: String = "yyyy-MM-dd HH:mm") -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.dateFormat = format
            return formatter.string(from: self)
    }
    
    init(string: String) {
        let format = "yyyy-MM-dd HH:mm"
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        self = formatter.date(from: string) ?? Date()
    }
}

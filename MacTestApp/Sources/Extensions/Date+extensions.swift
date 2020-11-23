//
//  Date+extensions.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 15.11.2020.
//

import Foundation

extension Date {
    func startOfWeek(using calendar: Calendar = Calendar.current) -> Date {
        calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
    
    func add(weeks: Int, using calendar: Calendar = Calendar.current) -> Date {
        var compontents = DateComponents()
        compontents.weekOfYear = weeks
        return calendar.date(byAdding: compontents, to: self)!
    }
    
    func endOfWeek(using calendar: Calendar = Calendar.current) -> Date {
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        if let weekOfYear = components.weekOfYear {
            components.weekOfYear = weekOfYear + 1
        }
        return calendar.date(from: components)!.addingTimeInterval(-1)
    }
    
    func dayPart(using calendar: Calendar = Calendar.current) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month, .day], from: self))!
    }
    
    func hour(using calendar: Calendar = Calendar.current) -> Int {
        calendar.dateComponents([.hour], from: self).hour!
    }
    
    func minutesFromDayStart(using calendar: Calendar = Calendar.current) -> Int {
        let components = calendar.dateComponents([.hour, .minute], from: self)
        
        return components.hour! * 60 + components.minute!
    }
    
    func isToday(using calendar: Calendar = Calendar.current) -> Bool {
        calendar.isDateInToday(self)
    }
    
    func isWeekday(using calendar: Calendar = Calendar.current) -> Bool {
        !calendar.isDateInWeekend(self)
    }
}

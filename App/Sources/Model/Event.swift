//
//  Event.swift
//  NextUp
//
//  Created by Petteri Kamppuri on 17.11.2020.
//

import Foundation

typealias Minutes = Int

struct Event: Codable {
    let id: String
    let calendar: EventCalendar
    let title: String
    
    let startDate: Date
    let endDate: Date
    
    let status: Status
    
    enum Status: String, Codable {
        case normal
        case canceled
        case tentative
    }
}

extension Event {
    var startTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: startDate)
    }
}

extension Event: Identifiable {}

//
//  Model.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 17.11.2020.
//

import EventKit

typealias Minutes = Int

struct Event: Codable {
    let id: String
    let calendar: EventCalendar
    let title: String
    
    let startDate: Date
    let endDate: Date
}

extension Event {
    var startTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: startDate)
    }
    
    static func from(_ event: EKEvent) -> Event {
        Event(
            id: event.eventIdentifier,
            calendar: EventCalendar.from(event.calendar),
            title: event.title,
            startDate: event.startDate,
            endDate: event.endDate
        )
    }
}

extension Event: Identifiable {}

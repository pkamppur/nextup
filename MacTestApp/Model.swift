//
//  Model.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 17.11.2020.
//

import EventKit

#if os(OSX)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

struct EventCalendar {
    let name: String
    
    #if os(OSX)
    let color: NSColor
    #elseif os(iOS)
    let color: UIColor
    #endif
}

typealias Minutes = Int

struct Event {
    let id: String
    let calendar: EventCalendar
    let title: String
    
    let startDate: Date
    let endDate: Date

    let start: Minutes // Minutes from day start
    let end: Minutes
    
    var startTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: startDate)
    }
    
    var duration: Minutes {
        end - start
    }
}

extension Event {
    static func from(_ event: EKEvent) -> Event {
        Event(
            id: event.eventIdentifier,
            calendar: EventCalendar.from(event.calendar),
            title: event.title,
            startDate: event.startDate,
            endDate: event.endDate,
            start: event.startDate.minutesFromDayStart(),
            end: event.endDate.minutesFromDayStart()
        )
    }
}

extension Event: Identifiable {}

extension EventCalendar {
    static func from(_ calendar: EKCalendar) -> EventCalendar {
        EventCalendar(
            name: calendar.title,
            color: calendar.color
        )
    }
}

struct Day {
    let date: Date
    let events: [Event]
}

extension Day: Identifiable {
    var id: Date { date }
}

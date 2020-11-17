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

struct Event {
    let calendar: EventCalendar
    let title: String
    let startHour: Int
    let endHour: Int
}

extension Event {
    static func from(_ event: EKEvent) -> Event {
        Event(
            calendar: EventCalendar.from(event.calendar),
            title: event.title,
            startHour: event.startDate.hour(),
            endHour: event.endDate.hour()
        )
    }
}

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

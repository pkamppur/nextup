//
//  EventService.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 15.11.2020.
//

import Foundation
import EventKit

class EventService {
    static let instance = EventService()
    
    private let store: EKEventStore
    
    private init() {
        store = EKEventStore()
    }
    
    func events(callback: @escaping ([Day]) -> Void) {
        switch EKEventStore.authorizationStatus(for: .event) {
            case .notDetermined:
                store.requestAccess(to: .event) { (granted, error) in
                    print("got access \(granted)")
                    callback(loadEvents(store: self.store))
                }
            case .authorized:
                callback(loadEvents(store: store))
            case .denied:
                fallthrough
            case .restricted:
                fallthrough
            @unknown default:
                print("Access denied")
        }
    }
}

private func loadEvents(store: EKEventStore) -> [Day] {
    let calendars: [EKCalendar] = store.calendars(for: .event)
    let date = Date().add(weeks: 1)
    
    print("Start of week \(formatDate(date.startOfWeek()))")
    print("End of week \(formatDate(date.endOfWeek()))")
    print("Next week start of week \(formatDate(date.startOfWeek().add(weeks: 1).startOfWeek()))")

    let predicate = store.predicateForEvents(withStart: date.startOfWeek(), end: date.endOfWeek(), calendars: calendars)
    let events = store.events(matching: predicate)
    
    let groupedEvents = Dictionary(grouping: events) { event in
        event.startDate.dayPart()
    }
    
    for (date, events) in groupedEvents {
        print("Day: \(formatDate(date))")
        
        for event in events {
            print("    Event: \(event)")
        }
    }
    
    return groupedEvents.mapValues { events in
        events.map { event in
            Event.from(event)
        }
    }.map {
        Day(date: $0.key, events: $0.value)
    }.sorted { (d1, d2) -> Bool in
        d1.date.compare(d2.date) == .orderedAscending
    }
}

private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    formatter.timeStyle = .medium

    return formatter.string(from: date)
}

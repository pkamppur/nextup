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
    private let stores: [EKEventStore]

    private init() {
        store = EKEventStore()
        let delegateStore = EKEventStore(sources: store.delegateSources)
        
        stores = [ store, delegateStore ]
    }
    
    func events(callback: @escaping ([Day]) -> Void) {
        switch EKEventStore.authorizationStatus(for: .event) {
            case .notDetermined:
                store.requestAccess(to: .event) { (granted, error) in
                    print("got access \(granted)")
                    callback(loadEvents(from: self.stores))
                }
            case .authorized:
                callback(loadEvents(from: stores))
            case .denied:
                fallthrough
            case .restricted:
                fallthrough
            @unknown default:
                print("Access denied")
        }
    }
}

private func loadEvents(from stores: [EKEventStore]) -> [Day] {
    let date = Date()
    let start = date.startOfWeek()
    let end = date.endOfWeek()

    print("Start of week \(formatDate(start))")
    print("End of week \(formatDate(end))")
    print("Next week start of week \(formatDate(start.add(weeks: 1).startOfWeek()))")
    
    let events = stores.flatMap { loadEvents(from: $0, start: start, end: end) }
    
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
    }
    .sorted { (d1, d2) -> Bool in
        d1.date.compare(d2.date) == .orderedAscending
    }
    .filter { $0.date.isWeekday() }
}

private func loadEvents(from store: EKEventStore, start: Date, end: Date) -> [EKEvent] {
    let calendars: [EKCalendar] = store.calendars(for: .event)

    let predicate = store.predicateForEvents(withStart: start, end: end, calendars: calendars)
    let events = store.events(matching: predicate)
    
    return events
}

private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    formatter.timeStyle = .medium

    return formatter.string(from: date)
}

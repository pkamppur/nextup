//
//  EventService.swift
//  NextUp
//
//  Created by Petteri Kamppuri on 15.11.2020.
//

import Foundation
import EventKit

class EventService {
    static let instance = EventService()
    
    private let initialStore: EKEventStore
    private var stores: [EKEventStore]

    private init() {
        initialStore = EKEventStore()
        stores = []
    }
    
    func events(forWeekContaining date: Date, callback: @escaping ([Day]) -> Void) {
        //callback(sampleEvents()); return
        let proceed = {
            self.createStores()

            let events = loadEvents(forWeekContaining: date, from: self.stores)
            
            /*{
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                
                let data = try! encoder.encode(events)
                let str = String(data: data, encoding: .utf8)!
                print("json: \(str)")
            }()*/
            
            /*for day in events {
                print("Day \(day.date)")
                for event in day.events {
                    print("    Events: \(event)")
                }
            }*/
            
            callback(events)
        }
        
        switch EKEventStore.authorizationStatus(for: .event) {
            case .notDetermined:
                initialStore.requestAccess(to: .event) { (granted, error) in
                    print("got access \(granted)")
                    proceed()
                }
            case .authorized:
                proceed()
            case .denied:
                fallthrough
            case .restricted:
                fallthrough
            @unknown default:
                print("Access denied")
        }
    }
    
    private func createStores() {
        if !stores.isEmpty {
            return
        }
        
        let delegateStore = EKEventStore(sources: initialStore.sources + initialStore.delegateSources)
        stores = [ delegateStore ]
    }
}

private func loadEvents(forWeekContaining: Date, from stores: [EKEventStore]) -> [Day] {
    let start = forWeekContaining.startOfWeek()
    let end = forWeekContaining.endOfWeek()

    print("Start of week \(formatDate(start))")
    print("End of week \(formatDate(end))")
    
    let events = stores.flatMap { loadEvents(from: $0, start: start, end: end) }
    
    let groupedEvents = Dictionary(grouping: events) { event in
        event.startDate.dayPart()
    }
    
    /*for (date, events) in groupedEvents {
        print("Day: \(formatDate(date))")
        
        for event in events {
            print("    Event: \(event)")
        }
    }*/
    
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
    
    print("**** store \(store), events \(events.count)")
    
    return events
}

private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    formatter.timeStyle = .medium

    return formatter.string(from: date)
}

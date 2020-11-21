//
//  ViewModel.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 20.11.2020.
//

import Foundation
import SwiftUI

struct DisplayEvent: Identifiable {
    let id: String
    let title: String
    let color: CodableColor
    let startTimeString: String
    let start: Minutes
    let end: Minutes
    let indentationLevel: Int
    let columnPos: Int
    let columnCount: Int
    
    var duration: Minutes {
        end - start
    }
}

class TempDisplayEvent {
    let id: String
    let start: Minutes
    let end: Minutes
    
    var children: [TempDisplayEvent]
    weak var parent: TempDisplayEvent?

    var indentationLevel: Int
    var columnPos: Int
    var columnCount: Int
    
    init(id: String, start: Minutes, end: Minutes) {
        self.id = id
        self.start = start
        self.end = end
        
        children = []
        parent = nil
        
        indentationLevel = 0
        columnPos = 0
        columnCount = 1
    }
    
    func overlaps(timeStamp: Minutes) -> Bool {
        start <= timeStamp && timeStamp < end
    }
}

extension Event {
    func overlaps(timeStamp: Minutes) -> Bool {
        start <= timeStamp && timeStamp < end
    }
    
    func overlaps(event: Event) -> Bool {
        (start <= event.start && event.start < end) ||
            (event.start <= start && start < event.end)
    }
}

func displayEvents(from events: [Event]) -> [DisplayEvent] {
    if events.isEmpty {
        return []
    }
    
    let tempDisplayEvents = events.map {
        TempDisplayEvent(id: $0.id, start: $0.start, end: $0.end)
    }
    
    /*
     var rawDisplayEvents = events.map {
         DisplayEvent(
             id: $0.id,
             title: $0.title,
             color: $0.calendar.color,
             startTimeString: $0.startTimeString,
             start: $0.start,
             end: $0.end,
             indentationLevel: 0,
             columnPos: 0,
             columnCount: 1
         )
     }

     */
    
    let earliestStart = events.reduce(Int.max) { (prev, event) in return min(prev, event.start) }
    let latestEnd = events.reduce(Int.min) { (prev, event) in return max(prev, event.end) }

    let eventTimeStamps = Array(Set(events.flatMap { [$0.start, $0.end] })).sorted()
    
    var groupedEvents = [Int:[TempDisplayEvent]]()
    
    let granularity: Minutes = 15
    for timeSlot in (earliestStart / granularity) ..< (latestEnd / granularity) {
        let overlappingEvents = tempDisplayEvents.filter { $0.overlaps(timeStamp: timeSlot * granularity) }
        
        groupedEvents[timeSlot] = overlappingEvents
    }
    
    
    
    print("earliestStart \(earliestStart), latestEnd \(latestEnd)")
    print("eventTimeStamps \(eventTimeStamps)")
    //print("groupedEvents \(groupedEvents)")

    for timeStamp in eventTimeStamps {
        print("timeStamp \(timeStamp)")
        
        for event in events {
            if event.overlaps(timeStamp: timeStamp) {
                print("    event \(event.title)")
            }
        }
    }
    
    let childToParentStartMinSeparation: Minutes = 30
    let eventsAndOverlaps = Dictionary(uniqueKeysWithValues: events.map { event in
        (id: event.id,
         children: events.filter { child in
            child.id != event.id
                && event.start + childToParentStartMinSeparation <= child.start
                && child.start < event.end
         }.map { $0.id },
         siblings: events.filter { sibling in
            sibling.id != event.id
                && event.overlaps(event: sibling)
         }.map { $0.id })
    }.map { info in
        (info.id,
         (id: info.id,
          children: info.children,
          siblings: info.siblings.filter { sibling in !info.children.contains(sibling)})
        )
    })
    
    let eventInfos = eventsAndOverlaps.mapValues { event in
        return (id: event.id,
         children: event.children,
         siblings: event.siblings,
         parent: eventsAndOverlaps.first { (_, value) in value.children.contains(event.id) }.map { $0.key } )
    }.mapValues { event in
        (id: event.id,
         children: event.children,
         siblings: event.siblings.filter { sibling in sibling != event.parent },
         parent: event.parent)
    }
    
    let eventLookup = Dictionary(uniqueKeysWithValues: events.map { ($0.id, $0) })
    
    return events.map { event in
        let eventInfo = eventInfos[event.id]!
        let isParent = eventInfo.parent == nil
        let parent = eventLookup[eventInfo.parent ?? "-"]
        
        print("event \(event.title)")
        print("    parent \(parent?.title ?? "<none>")")
        print("    siblings \(eventInfo.siblings.map { sibling in eventLookup[sibling]! }.map { $0.title })")

        let siblingIds = Set([event.id] + eventInfo.siblings)
        let siblingEvents = events.map { $0.id }.filter { siblingIds.contains($0) }
        let columnPos = siblingEvents.firstIndex(of: event.id) ?? 0
        
        return DisplayEvent(
            id: event.id,
            title: event.title,
            color: event.calendar.color,
            startTimeString: event.startTimeString,
            start: event.start,
            end: event.end,
            indentationLevel: isParent ? 0 : 1,
            columnPos: columnPos,
            columnCount: eventInfo.siblings.count + 1
        )
    }

    
    //print("parents \(eventsAndOverlaps.map { ($0.0.title, $0.1.map {event in event.title}) })")

    /*for event in tempDisplayEvents {
        if event
    }*/
    
    let eventGroups = eventTimeStamps.map { timeStamp in
        tempDisplayEvents.filter { event in
            event.overlaps(timeStamp: timeStamp)
        }
    }
    
    //for timeSlot in groupedEvents.keys.sorted() {
    //    let events = groupedEvents[timeSlot]!
    for events in eventGroups {
        if events.count <= 1 {
            continue
        }
        
        var column = 0
        let maxColumns = max(events.count, events.reduce(0) { (prev, event) in return max(prev, event.columnCount) })
        for event in events {
            if event.columnCount < maxColumns {
                event.columnPos = column
                event.columnCount = maxColumns
            }
            
            column += 1
        }
    }
    
    return tempDisplayEvents.map { temp in
        let event = events.first { $0.id == temp.id }!
        
        return DisplayEvent(
            id: event.id,
            title: event.title,
            color: event.calendar.color,
            startTimeString: event.startTimeString,
            start: event.start,
            end: event.end,
            indentationLevel: temp.indentationLevel,
            columnPos: temp.columnPos,
            columnCount: temp.columnCount
        )
    }
}

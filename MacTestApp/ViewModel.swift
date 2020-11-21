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
    
    func overlaps(_ time: Minutes) -> Bool {
        start <= time && time < end
    }
}

extension Event {
    func overlaps(_ time: Minutes) -> Bool {
        start <= time && time < end
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
        let overlappingEvents = tempDisplayEvents.filter { $0.overlaps(timeSlot * granularity) }
        
        groupedEvents[timeSlot] = overlappingEvents
    }
    
    
    
    print("earliestStart \(earliestStart), latestEnd \(latestEnd)")
    print("eventTimeStamps \(eventTimeStamps)")
    print("groupedEvents \(groupedEvents)")

    for timeStamp in eventTimeStamps {
        print("timeStamp \(timeStamp)")
        
        for event in events {
            if event.overlaps(timeStamp) {
                print("    event \(event.title)")
            }
        }
    }
    
    /*for event in tempDisplayEvents {
        if event
    }*/
    
    for timeSlot in groupedEvents.keys.sorted() {
        let events = groupedEvents[timeSlot]!
        
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

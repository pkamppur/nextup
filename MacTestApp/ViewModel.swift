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

final class WeakBox<T: AnyObject> {
    weak var value: T?
    init(_ value: T) {
        self.value = value
    }
}

struct WeakArray<T: AnyObject> {
    
}

final class TempDisplayEvent {
    let title: String
    let id: String
    let start: Minutes
    let end: Minutes
    
    var children: [TempDisplayEvent]
    weak var parent: TempDisplayEvent?
    private var _siblings: [WeakBox<TempDisplayEvent>]

    var indentationLevel: Int
    var columnPos: Int
    var columnCount: Int
    
    init(title: String, id: String, start: Minutes, end: Minutes) {
        self.title = title
        self.id = id
        self.start = start
        self.end = end
        
        children = []
        parent = nil
        _siblings = []
        
        indentationLevel = 0
        columnPos = 0
        columnCount = 1
    }
    
    func overlaps(timeStamp: Minutes) -> Bool {
        start <= timeStamp && timeStamp < end
    }
    
    func addChild(_ child: TempDisplayEvent) {
        children.append(child)
        child.parent = self
    }
    
    func addSibling(_ sibling: TempDisplayEvent) {
        _siblings.append(WeakBox(sibling))
    }
    
    var siblings: [TempDisplayEvent] {
        _siblings.compactMap { $0.value }
    }
    
    func setSiblings(_ siblings: [TempDisplayEvent]) {
        _siblings = siblings.map { WeakBox($0) }
    }
    
    func overlaps(event: TempDisplayEvent) -> Bool {
        (start <= event.start && event.start < end) ||
            (event.start <= start && start < event.end)
    }
}

extension TempDisplayEvent: CustomDebugStringConvertible {
    var debugDescription: String {
        title
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
        TempDisplayEvent(title: $0.title, id: $0.id, start: $0.start, end: $0.end)
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
    
    
    
    /*print("earliestStart \(earliestStart), latestEnd \(latestEnd)")
    print("eventTimeStamps \(eventTimeStamps)")
    //print("groupedEvents \(groupedEvents)")

    for timeStamp in eventTimeStamps {
        print("timeStamp \(timeStamp)")
        
        for event in events {
            if event.overlaps(timeStamp: timeStamp) {
                print("    event \(event.title)")
            }
        }
    }*/
    
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
          siblings: info.siblings.filter { sibling in !info.children.contains(sibling) })
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
    /*
    return events.map { event in
        let eventInfo = eventInfos[event.id]!
        let isParent = eventInfo.parent == nil
        let parent = eventLookup[eventInfo.parent ?? "-"]
        
        print("event \(event.title)")
        print("    parent \(parent?.title ?? "<none>")")
        print("    siblings \(eventInfo.siblings.map { sibling in eventLookup[sibling]! }.map { $0.title })")
        
        let siblingIds = Set([event.id] + eventInfo.siblings)
        let siblingEvents = events.filter { siblingIds.contains($0.id) }.filter { !(event.start - $0.start >= 15 && eventInfos[$0.id]!.siblings.count == 1) }
        let columnPos = siblingEvents.map { $0.id }.firstIndex(of: event.id) ?? 0
        print("    siblingEvents \(siblingEvents.map { $0.title })")

        return DisplayEvent(
            id: event.id,
            title: event.title,
            color: event.calendar.color,
            startTimeString: event.startTimeString,
            start: event.start,
            end: event.end,
            indentationLevel: isParent ? 0 : 1,
            columnPos: columnPos,
            columnCount: siblingEvents.count
        )
    }*/

    
    //print("parents \(eventsAndOverlaps.map { ($0.0.title, $0.1.map {event in event.title}) })")

    /*for event in tempDisplayEvents {
        if event
    }*/
    
    let eventGroups = eventTimeStamps.map { timeStamp in
        tempDisplayEvents.filter { event in
            event.overlaps(timeStamp: timeStamp)
        }
    }
    
    // Find parents
    for event in tempDisplayEvents {
        let parentIds = eventsAndOverlaps.filter { (_, value) in value.children.contains(event.id) }.map { $0.key }
        let parents = tempDisplayEvents.filter { parentIds.contains($0.id) }
        
        if !parents.isEmpty {
            for parent in parents {
                if parent.children.isEmpty {
                    parent.addChild(event)
                    break
                }
            }
            
            if event.parent == nil {
                let parentWithLeastChildren = parents.sorted { $0.children.count < $1.children.count }.first!
                parentWithLeastChildren.addChild(event)
            }
        }
    }
    
    print("-------------------")
    
    let parentEvents = tempDisplayEvents.filter { $0.parent == nil }
    for event in tempDisplayEvents {
        let potentialSiblings: [TempDisplayEvent]
        if let parent = event.parent {
            potentialSiblings = parent.children
        } else {
            potentialSiblings = parentEvents
        }
        
        let siblings = potentialSiblings.filter { sibling in
            sibling.id != event.id && event.overlaps(event: sibling)
        }
        event.setSiblings(siblings)
    }
    
    for event in tempDisplayEvents {
        let trueSiblingOverlapThreshold: Minutes = 15
        let siblingIds = Set([event.id] + event.siblings.map { $0.id })
        let siblingEvents = tempDisplayEvents.filter { siblingIds.contains($0.id) }
        let overlapping = siblingEvents.filter { $0.end - trueSiblingOverlapThreshold <= event.start }
        let trueSiblings = siblingEvents.filter { sibling in !overlapping.contains { sibling.id == $0.id } }
        let columnPos = trueSiblings.firstIndex { $0.id == event.id } ?? 0
        let columnSiblings = trueSiblings//.filter { event.end - trueSiblingOverlapThreshold <= $0.start || event.start <= $0.start }

        print("event \(event)")
        if let parent = event.parent {
            print("    parent \(parent)")
        }
        if !event.siblings.isEmpty {
            print("    siblings \(event.siblings)")
        }
        if !trueSiblings.isEmpty {
            print("    true siblings \(trueSiblings)")
        }
        if !overlapping.isEmpty {
            print("    overlapping \(overlapping)")
        }
        if !columnSiblings.isEmpty {
            print("    columnSiblings \(columnSiblings)")
        }

        event.children.first?.indentationLevel += 1
        
        event.indentationLevel += overlapping.count > 0 && overlapping.first!.id != event.id ? 1 : 0
        event.columnPos = columnPos
        event.columnCount = max(1, columnSiblings.count)
    }
    for event in tempDisplayEvents {
        if let parent = event.parent {
            event.columnPos += parent.columnPos
            event.columnCount += parent.columnCount - 1
        }
    }
    /*
    for event in tempDisplayEvents {
        let parentDepth: Int = { initial in
            var current: TempDisplayEvent? = initial
            var i = -1
            while current != nil {
                current = current?.parent
                i += 1
            }
            return i
        }(event)
        
        let siblingIds = Set([event.id] + event.siblings.map { $0.id })
        let siblingEvents = events.filter { siblingIds.contains($0.id) }//.filter { !(event.start - $0.start >= 15 && eventInfos[$0.id]!.siblings.count == 1) }
        let columnPos = siblingEvents.map { $0.id }.firstIndex(of: event.id) ?? 0

        event.indentationLevel = columnPos == 0 ? parentDepth : 0
        event.columnPos = columnPos
        event.columnCount = siblingEvents.count
    }*/
    
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

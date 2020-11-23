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

func displayEvents(from events: [Event]) -> [DisplayEvent] {
    if events.isEmpty {
        return []
    }
    
    let tempDisplayEvents = events.map {
        TempDisplayEvent(
            title: $0.title,
            id: $0.id,
            start: $0.startDate.minutesFromDayStart(),
            end: $0.endDate.minutesFromDayStart()
        )
    }
    
    let childToParentStartMinSeparation: Minutes = 30
    let eventsAndOverlaps = Dictionary(uniqueKeysWithValues: tempDisplayEvents.map { event in
        (id: event.id,
         children: tempDisplayEvents.filter { child in
            child.id != event.id
                && event.start + childToParentStartMinSeparation <= child.start
                && child.start < event.end
         }.map { $0.id })
    }.map { info in
        (info.id,
         (id: info.id, children: info.children)
        )
    })
    
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
    
    let trueSiblingOverlapThreshold: Minutes = 15
    
    for event in tempDisplayEvents {
        let siblingIds = Set([event.id] + event.siblings.map { $0.id })
        let siblingEvents = tempDisplayEvents.filter { siblingIds.contains($0.id) }
        let overlapping = siblingEvents.filter { $0.end - trueSiblingOverlapThreshold <= event.start }
        let columnSiblings = siblingEvents.filter { sibling in !overlapping.contains { sibling.id == $0.id } }
        let columnPos = columnSiblings.firstIndex { $0.id == event.id } ?? 0
        
        print("event \(event)")
        if let parent = event.parent {
            print("    parent \(parent)")
        }
        if !event.siblings.isEmpty {
            print("    siblings \(event.siblings)")
        }
        if !columnSiblings.isEmpty {
            print("    column siblings \(columnSiblings)")
        }
        if !overlapping.isEmpty {
            print("    overlapping \(overlapping)")
        }

        //event.children.first?.indentationLevel += 1
        
        event.columnPos = columnPos
        event.columnCount = max(1, columnSiblings.count)
        event.indentationLevel += overlapping.count > 0 && overlapping.first!.id != event.id && columnPos == 0 ? 1 : 0
        
        if (event.columnCount == 1 && event.parent != nil)
            || event.id == event.siblings.sorted(by: { $0.columnPos < $1.columnPos }).first?.id
            || (event.siblings.count == 0 && event.parent != nil)
            || event.parent?.children.first?.id == event.id {
            event.indentationLevel += 1
        }
    }
    
    for event in tempDisplayEvents {
        if let parent = event.parent {
            event.columnPos += parent.columnPos
            event.columnCount += parent.columnCount - 1
        }
    }
    
    for event in tempDisplayEvents {
        let overlapping = tempDisplayEvents.filter { $0.id != event.id && $0.overlaps(event: event) && $0.id != event.parent?.id }
        let hasntGotColumnSiblings = overlapping.allSatisfy { event.end - trueSiblingOverlapThreshold <= $0.start }

        if overlapping.count == 0
            || (overlapping.count == 1 && overlapping.first!.id == event.parent?.id)
            || (hasntGotColumnSiblings) {
            event.columnPos = 0
            event.columnCount = 1
        }
    }
    
    return tempDisplayEvents.map { temp in
        let event = events.first { $0.id == temp.id }!
        
        return DisplayEvent(
            id: event.id,
            title: event.title,
            color: event.calendar.color,
            startTimeString: event.startTimeString,
            start: temp.start,
            end: temp.end,
            indentationLevel: temp.indentationLevel,
            columnPos: temp.columnPos,
            columnCount: temp.columnCount
        )
    }
}

private final class TempDisplayEvent {
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

//
//  ViewModelCreationTests.swift
//  Unit Tests
//
//  Created by Petteri Kamppuri on 23.11.2020.
//

import XCTest
@testable import NextUp

class ViewModelCreationTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSimpleNonOverlappingEvents() throws {
        let firstEvent = Event.create("First", start: "14:00", end: "15:00")
        let secondEvent = Event.create("Second", start: "15:00", end: "16:00")
        
        let res = displayEvents(from: [ firstEvent, secondEvent ])
        
        XCTAssertEqual(res[0].title, "First")
        XCTAssertEqual(res[0].layout, "0|1-1")
        
        XCTAssertEqual(res[1].title, "Second")
        XCTAssertEqual(res[1].layout, "0|1-1")
    }

    func testShortEventShouldHaveLimitedTitleHeight() throws {
        let shortEvent = Event.create("Short", start: "14:00", end: "14:30")
        
        let res = displayEvents(from: [ shortEvent ])
        
        XCTAssertEqual(res[0].title, "Short")
        XCTAssertEqual(res[0].layout, "0|1-1")
        XCTAssertEqual(res[0].maxTitleHeight, 30)
    }

    func testFirstChildLimitsTitleHeight() throws {
        let parent = Event.create("Parent", start: "14:00", end: "15:00")
        let child = Event.create("Child", start: "14:30", end: "15:15")

        let res = displayEvents(from: [ parent, child ])
        
        XCTAssertEqual(res[0].title, "Parent")
        XCTAssertEqual(res[0].maxTitleHeight, 30)
        
        XCTAssertEqual(res[1].title, "Child")
        XCTAssertEqual(res[1].maxTitleHeight, 45)
    }

    func testChildIsIndented() throws {
        let parent = Event.create("Parent", start: "14:00", end: "15:00")
        let child = Event.create("Child", start: "14:30", end: "15:00")

        let res = displayEvents(from: [ parent, child ])
        
        XCTAssertEqual(res[0].title, "Parent")
        XCTAssertEqual(res[0].layout, "0|1-1")
        
        XCTAssertEqual(res[1].title, "Child")
        XCTAssertEqual(res[1].layout, "1|1-1")
    }

    func testChildOfChildIsIndentedTwoLevels() throws {
        let parent = Event.create("Parent", start: "14:00", end: "15:00")
        let child = Event.create("Child", start: "14:30", end: "15:30")
        let secondChild = Event.create("Second Child", start: "15:00", end: "15:30")

        let res = displayEvents(from: [ parent, child, secondChild ])
        
        XCTAssertEqual(res[0].title, "Parent")
        XCTAssertEqual(res[0].layout, "0|1-1")
        
        XCTAssertEqual(res[1].title, "Child")
        XCTAssertEqual(res[1].layout, "1|1-1")
        
        XCTAssertEqual(res[2].title, "Second Child")
        XCTAssertEqual(res[2].layout, "2|1-1")
    }

    func testChildrenAreSpreadToParents() throws {
        let parent1 = Event.create("Parent1", start: "12:00", end: "16:00")
        let parent2 = Event.create("Parent2", start: "12:00", end: "14:00")
        let parent3 = Event.create("Parent3", start: "12:00", end: "14:00")
        let child1 = Event.create("Child1", start: "12:45", end: "13:45")
        let child2 = Event.create("Child2", start: "13:00", end: "14:00")

        let res = displayEvents(from: [ parent1, parent2, parent3, child1, child2 ])
        
        XCTAssertEqual(res[0].title, "Parent1")
        XCTAssertEqual(res[0].layout, "0|1-3")
        
        XCTAssertEqual(res[1].title, "Parent2")
        XCTAssertEqual(res[1].layout, "0|2-3")
        
        XCTAssertEqual(res[2].title, "Parent3")
        XCTAssertEqual(res[2].layout, "0|3-3")
        
        XCTAssertEqual(res[3].title, "Child1")
        XCTAssertEqual(res[3].layout, "1|1-3")
        
        XCTAssertEqual(res[4].title, "Child2")
        XCTAssertEqual(res[4].layout, "1|2-3")
    }

    func testEventWithShortChildAndTwoSiblingChildrenLater() throws {
        let spanningEvent = Event.create("Spanning", start: "14:00", end: "16:45")
        let shortOverlappingEvent = Event.create("Short", start: "14:15", end: "14:30")
        let mediumOverlappingEvent = Event.create("Med1", start: "16:00", end: "17:00")
        let mediumOverlappingEvent2 = Event.create("Med2", start: "16:00", end: "17:00")
        let events = [ spanningEvent, shortOverlappingEvent, mediumOverlappingEvent, mediumOverlappingEvent2 ]
        
        let res = displayEvents(from: events)
        
        XCTAssertEqual(res[0].title, "Spanning")
        XCTAssertEqual(res[0].layout, "0|1-2")
        
        XCTAssertEqual(res[1].title, "Short")
        XCTAssertEqual(res[1].layout, "0|2-2")
        
        XCTAssertEqual(res[2].title, "Med1")
        XCTAssertEqual(res[2].layout, "1|1-2")
        
        XCTAssertEqual(res[3].title, "Med2")
        XCTAssertEqual(res[3].layout, "0|2-2")
        
    }
    
    func testss() throws {
        let first = Event.create("First", start: "12:00", end: "13:00")
        let second = Event.create("Second", start: "12:15", end: "13:15")
        let sibling = Event.create("Sibling", start: "13:00", end: "14:00")
        let indentedSibling = Event.create("IndentedSibling", start: "13:00", end: "14:00")
        let events = [ first, second, sibling, indentedSibling ]
        
        let res = displayEvents(from: events)
        
        XCTAssertEqual(res[0].title, "First")
        XCTAssertEqual(res[0].layout, "0|1-2")
        
        XCTAssertEqual(res[1].title, "Overlapping")
        XCTAssertEqual(res[1].layout, "0|2-2")
        
        XCTAssertEqual(res[2].title, "Sibling")
        XCTAssertEqual(res[2].layout, "0|1-2")
        
        XCTAssertEqual(res[3].title, "IndentedSibling")
        XCTAssertEqual(res[3].layout, "1|2-2")
    }
    
    
    func testShortEventWithOverlappingNextEventWhichHasTwoSiblings() throws {
        let shortEvent = Event.create("Short", start: "12:30", end: "13:00")
        let overlappingEvent = Event.create("Overlapping", start: "12:45", end: "13:45")
        let sibling1 = Event.create("Sibling1", start: "13:00", end: "14:00")
        let sibling2 = Event.create("Sibling2", start: "13:00", end: "14:00")
        let events = [ shortEvent, overlappingEvent, sibling1, sibling2 ]
        
        let res = displayEvents(from: events)
        
        XCTAssertEqual(res[0].title, "Short")
        XCTAssertEqual(res[0].layout, "0|1-1")
        
        XCTAssertEqual(res[1].title, "Overlapping")
        XCTAssertEqual(res[1].layout, "1|1-3")
        
        XCTAssertEqual(res[2].title, "Sibling1")
        XCTAssertEqual(res[2].layout, "0|2-3")
        
        XCTAssertEqual(res[3].title, "Sibling2")
        XCTAssertEqual(res[3].layout, "0|3-3")
    }
}

fileprivate var eventId = 0
fileprivate func nextEventId() -> String {
    eventId += 1
    
    return "\(eventId)"
}

extension Event {
    static func create(_ title: String, start: String, end: String) -> Self {
        let id = nextEventId()
        let dateFormatter = ISO8601DateFormatter()
        
        let startTs = "2020-01-01T\(start):00Z"
        let endTs = "2020-01-01T\(end):00Z"

        return Self(
            id: id,
            calendar: createCalendar(for: id),
            title: title,
            startDate: dateFormatter.date(from: startTs)!,
            endDate: dateFormatter.date(from: endTs)!,
            status: .normal
        )
    }
}

func createCalendar(for id: String) -> EventCalendar {
    EventCalendar(name: id + "-cal", color: CodableColor(white: 1, alpha: 1))
}

extension DisplayEvent: CustomDebugStringConvertible {
    var debugDescription: String {
        "DisplayEvent(id: \"\(id)\", id: \"\(title)\", indentation: \(indentationLevel), columnPos: \(columnPos), columnCount: \(columnCount))"
    }
    
    var layout: String {
        "\(indentationLevel)|\(columnPos + 1)-\(columnCount)"
    }
}

//
//  ViewModelCreationTests.swift
//  MacTestAppTests
//
//  Created by Petteri Kamppuri on 23.11.2020.
//

import XCTest
@testable import MacTestApp

class ViewModelCreationTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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

    func test___SOMETHING() throws {
        let spanningEvent = Event.create("Spanning", start: "14:00", end: "16:45")
        let shortOverlappingEvent = Event.create("Short", start: "14:15", end: "14:30")
        let mediumOverlappingEvent = Event.create("Med1", start: "16:00", end: "17:00")
        let mediumOverlappingEvent2 = Event.create("Med2", start: "16:00", end: "17:00")
        let events = [ spanningEvent, shortOverlappingEvent, mediumOverlappingEvent, mediumOverlappingEvent2 ]
        
        let res = displayEvents(from: events)
        
        XCTAssertEqual(res[0].title, "Spanning")
        XCTAssertEqual(res[0].layout, "0|1-2")
        
        XCTAssertEqual(res[1].title, "Short")
        XCTAssertEqual(res[1].layout, "0|1-2")
        
        XCTAssertEqual(res[2].title, "Med1")
        XCTAssertEqual(res[2].layout, "1|1-2")
        
        XCTAssertEqual(res[3].title, "Med2")
        XCTAssertEqual(res[3].layout, "0|2-2")
        
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
            endDate: dateFormatter.date(from: endTs)!
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

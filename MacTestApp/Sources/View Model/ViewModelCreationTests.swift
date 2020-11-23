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

    func test___SOMETHING() throws {
        let spanningEvent = Event.create("1", title: "Spanning", start: "14:00", end: "16:45")
        let shortOverlappingEvent = Event.create("2", title: "Short", start: "14:15", end: "14:30")
        let mediumOverlappingEvent = Event.create("3", title: "Med1", start: "16:00", end: "17:00")
        let mediumOverlappingEvent2 = Event.create("4", title: "Med2", start: "16:00", end: "17:00")
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

extension Event {
    static func create(_ id: String, title: String, start: String, end: String) -> Self {
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

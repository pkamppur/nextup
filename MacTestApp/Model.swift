//
//  Model.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 17.11.2020.
//

import EventKit

#if os(OSX)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

struct CodableColor: Codable {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat

    init(cgColor: CGColor) {
        let rgbColor = cgColor.converted(
            to: CGColorSpace(name: CGColorSpace.sRGB)!,
            intent: CGColorRenderingIntent.defaultIntent,
            options: nil
        )!
        
        let components = rgbColor.components!
        
        red = components[0]
        green = components[1]
        blue = components[2]
        alpha = components[3]
    }
    
    #if os(OSX)
    var nsColor: NSColor {
        return NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    init(nsColor: NSColor) {
        red = 0
        green = 0
        blue = 0
        alpha = 0
        nsColor.usingColorSpace(NSColorSpace.extendedSRGB)!.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
    #elseif os(iOS)
    var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    init(uiColor: UIColor) {
        red = 0
        green = 0
        blue = 0
        alpha = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
    #endif
}

struct EventCalendar: Codable {
    let name: String
    let color: CodableColor
}

typealias Minutes = Int

struct Event: Codable {
    let id: String
    let calendar: EventCalendar
    let title: String
    
    let startDate: Date
    let endDate: Date
}

extension Event {
    var startTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: startDate)
    }
    
    static func from(_ event: EKEvent) -> Event {
        Event(
            id: event.eventIdentifier,
            calendar: EventCalendar.from(event.calendar),
            title: event.title,
            startDate: event.startDate,
            endDate: event.endDate
        )
    }
}

extension Event: Identifiable {}

extension EventCalendar {
    static func from(_ calendar: EKCalendar) -> EventCalendar {
        EventCalendar(
            name: calendar.title,
            color: CodableColor(cgColor: calendar.color.cgColor)
        )
    }
}

struct Day: Codable {
    let date: Date
    let events: [Event]
}

extension Day: Identifiable {
    var id: Date { date }
}

extension Day {
    func json() -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        return try! encoder.encode(self)
    }
    
    static func fromJson(_ data: Data) -> Self {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try! decoder.decode(Self.self, from: data)
    }
}

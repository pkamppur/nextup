//
//  EventCalendar.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 23.11.2020.
//

import Foundation
import EventKit

struct EventCalendar: Codable {
    let name: String
    let color: CodableColor
}

extension EventCalendar {
    static func from(_ calendar: EKCalendar) -> EventCalendar {
        EventCalendar(
            name: calendar.title,
            color: CodableColor(cgColor: calendar.color.cgColor)
        )
    }
}

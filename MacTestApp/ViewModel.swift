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
    return events.map {
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
}

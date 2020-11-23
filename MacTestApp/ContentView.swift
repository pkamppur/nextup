//
//  ContentView.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 15.11.2020.
//

import SwiftUI

struct ContentView: View {
    @State private var thisWeek: [Day] = Array(repeating: Day(date: Date.distantPast, events: []), count: 5)
    @State private var nextWeek: [Day] = Array(repeating: Day(date: Date.distantPast, events: []), count: 5)

    var body: some View {
        VStack {
            WeekCalendarView(days: thisWeek)
            WeekCalendarView(days: nextWeek)
        }
        .onAppear() {
            EventService.instance.events(forWeekContaining: Date()) { events in
                thisWeek = events
            }
            
            EventService.instance.events(forWeekContaining: Date().add(weeks: 1)) { events in
                nextWeek = events
            }
        }
    }
}

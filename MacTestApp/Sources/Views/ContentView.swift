//
//  ContentView.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 15.11.2020.
//

import SwiftUI

struct ContentView: View {
    @State private var firstWeek: [Day] = Array(repeating: Day(date: Date.distantPast, events: []), count: 5)
    @State private var secondWeek: [Day] = Array(repeating: Day(date: Date.distantPast, events: []), count: 5)

    var body: some View {
        VStack {
            WeekCalendarView(days: firstWeek)
            WeekCalendarView(days: secondWeek)
        }
        .onAppear() {
            EventService.instance.events(forWeekContaining: Date()) { events in
                firstWeek = events
            }
            
            EventService.instance.events(forWeekContaining: Date().add(weeks: 1)) { events in
                secondWeek = events
            }
        }
    }
}

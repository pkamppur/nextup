//
//  ContentView.swift
//  NextUp
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
            EventService.instance.events(forWeekContaining: firstWeekDate) { events in
                firstWeek = events
            }
            
            EventService.instance.events(forWeekContaining: secondWeekDate) { events in
                secondWeek = events
            }
        }
    }
    
    var firstWeekDate: Date {
        let now = Date()
        
        return now.isWeekday() ? now : now.add(weeks: 1)
    }
    
    var secondWeekDate: Date {
        firstWeekDate.add(weeks: 1)
    }
}
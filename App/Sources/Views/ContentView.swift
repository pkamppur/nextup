//
//  ContentView.swift
//  NextUp
//
//  Created by Petteri Kamppuri on 15.11.2020.
//

import SwiftUI
import EventKit

struct ContentView: View {
    @State private var firstWeek: [Day] = Array(repeating: Day(date: Date.distantPast, events: []), count: 5)
    @State private var secondWeek: [Day] = Array(repeating: Day(date: Date.distantPast, events: []), count: 5)
    @State private var now = Date()
    
    private let updateTimer = Timer.publish(every: 60, tolerance: 5, on: .main, in: .common).autoconnect()
    private let calendarChanged = NotificationCenter.default.publisher(for: .EKEventStoreChanged).receive(on: DispatchQueue.main)
    
    var body: some View {
        VStack {
            WeekCalendarView(now: now, days: firstWeek)
            WeekCalendarView(now: now, days: secondWeek)
        }
        .onAppear() {
            updateData()
        }
        .onReceive(calendarChanged) { _ in
            print("Got items")
            updateData()
        }
        .onReceive(updateTimer) { _ in
            print("Timer!!")
            updateData()
        }
    }
    
    var firstWeekDate: Date {
        return now.isWeekday() ? now : now.add(weeks: 1)
    }
    
    var secondWeekDate: Date {
        firstWeekDate.add(weeks: 1)
    }
    
    private func updateData() {
        now = Date()
        
        EventService.instance.events(forWeekContaining: firstWeekDate) { events in
            if firstWeek != events {
                firstWeek = events
            }
        }
        
        EventService.instance.events(forWeekContaining: secondWeekDate) { events in
            if secondWeek != events {
                secondWeek = events
            }
        }
    }
}

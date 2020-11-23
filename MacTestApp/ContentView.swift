//
//  ContentView.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 15.11.2020.
//

import SwiftUI

struct ContentView: View {
    @State private var days: [Day] = Array(repeating: Day(date: Date.distantPast, events: []), count: 5)
    
    var body: some View {
        WeekCalendarView(days: days)
            .onAppear() {
                EventService.instance.events(forWeekContaining: Date()) { events in
                    days = events
                }
            }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WeekCalendarView(days: sampleEvents())
            .frame(width: 1000.0, height: 800.0)
    }
}

func sampleEvents() -> [Day] {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let data = NSDataAsset(name: "events.json")!.data
    
    let events = try! decoder.decode([Day].self, from: data)
    
    return events
}

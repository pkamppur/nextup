//
//  ContentView.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 15.11.2020.
//

import SwiftUI

struct ContentView: View {
    @State private var days: [Day] = Array(repeating: Day(date: Date(), events: []), count: 7)
    
    var body: some View {
        HStack(spacing: 0) {
            HourHeaderColumn()
                .frame(maxWidth: 70)
            ForEach(days) { day in
                DayColumn(events: day.events)
            }
        }
        .background(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            EventService.instance.events { events in
                for day in events {
                    print("Day \(day.date)")
                    for event in day.events {
                        print("    Events: \(event)")
                    }
                }
                
                days = events
            }
        }
    }
}


let gridColor = Color(white: 0.89, opacity: 1)


struct DayColumn: View {
    let events: [Event]
    
    var body: some View {
        HourlyColumn() { config in
            ZStack {
                VStack(spacing: 0) {
                    ForEach(config.hours) { hour in
                        Color.init(white: 1, opacity: 0)
                            .frame(maxWidth: .infinity)
                            .frame(height: config.hourSize.height)
                            .border(edges: [.top, .trailing], color: gridColor)
                    }
                }
                
                ForEach(events) { event in
                    let frame = config.frameFor(start: event.start, end: event.end)
                    let eventColor = event.calendar.color
                    
                    Color(eventColor)
                        .opacity(0.25)
                        .overlay(
                            HStack(alignment: .top, spacing: 0) {
                                Color(eventColor)
                                    .frame(width: 2)
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    if event.duration > 30 {
                                        Text(event.startTimeString)
                                            .padding([ .top ], 2)
                                    }
                                    
                                    Text(event.title)
                                        .bold()
                                        .padding([ .top ], 0)
                                }
                                .foregroundColor(Color(eventColor.darker(by: 0.6)).opacity(0.8))
                                .font(.caption)
                                .padding([ .leading ], 2)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        )
                        .cornerRadius(2)
                        .frame(frame)
                }
            }
        }
    }
}


struct HourHeaderColumn: View {
    var body: some View {
        HourlyColumn() { config in
            VStack(spacing: 0) {
                ForEach(config.hours) { hour in
                    Text("\(hour).00")
                        .font(.caption)
                        .foregroundColor(gridColor)
                        .padding(.trailing, 5)
                        .padding(.top, -3)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .frame(height: config.hourSize.height)
                }
            }
        }
    }
}

struct HourConfig {
    let hours: Range<Int>
    let hourSize: CGSize
    let areaSize: CGSize
    private let hourBoxInset: CGFloat = 2
    
    func frameFor(start: Int, end: Int) -> CGRect {
        CGRect(
            x: 0,
            y: hourSize.height * (CGFloat(start) / 60 - CGFloat(hours.first!) + 0.5) + hourBoxInset,
            width: hourSize.width - hourBoxInset,
            height: hourSize.height * CGFloat(end - start) / 60 - hourBoxInset
        )
    }
}

struct HourlyColumn<Content: View>: View {
    private let startHour = 8
    private let endHour = 17
    let content: (HourConfig) -> Content
    
    var body: some View {
        let hours = endHour - startHour + 2 // Show one hour even if start==end, plus 1 hour spacing divided above and below
        
        return GeometryReader { geometry in
            //ZStack {
                content(
                    HourConfig(
                        hours: startHour..<endHour+1,
                        hourSize: CGSize(width: geometry.size.width, height: geometry.size.height / CGFloat(hours)),
                        areaSize: CGSize(width: geometry.size.width, height: geometry.size.height)
                    )
                )
            //}
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 1000.0, height: 800.0)
    }
}

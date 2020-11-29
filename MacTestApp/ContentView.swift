//
//  ContentView.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 15.11.2020.
//

import SwiftUI

struct HeaderText: View {
    let text: String
    
    var body: some View {
        Text(text)
            .padding([ .top ], 20)
            .padding([ .bottom ], 10)
            .font(.subheadline)
    }
}

struct ContentView: View {
    @State private var days: [Day] = Array(repeating: Day(date: Date.distantPast, events: []), count: 5)
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .trailing, spacing: 0) {
                HeaderText(text: "W1")
                HourHeaderColumn()
            }
            .frame(maxWidth: 70)
            
            ForEach(days) { day in
                VStack(spacing: 0) {
                    HeaderText(text: formatDayTitle(day.date))
                    DayColumn(isToday: day.date.isToday(), events: day.events)
                }
            }
        }
        .background(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        /*.onAppear() {
            EventService.instance.events { events in
                for day in events {
                    print("Day \(day.date)")
                    for event in day.events {
                        print("    Events: \(event)")
                    }
                }
                
                days = events
            }
        }*/
        .onAppear() {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let data = NSDataAsset(name: "events.json")!.data
            
            let events = try! decoder.decode([Day].self, from: data)
            days = events
        }
    }
}


let gridColor = Color(white: 0.89, opacity: 1)


struct DayColumn: View {
    let isToday: Bool
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
                .if(isToday) {
                    $0
                        .border(width: 2, edges: [.leading, .trailing], color: Color.red.opacity(0.5))
                        .background(Color.red.opacity(0.04))
                }
                
                ForEach(events) { event in
                    let frame = config.frameFor(start: event.start, end: event.end)
                    let eventColor = event.calendar.color.nsColor
                    
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
                        //.cornerRadius(2)
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
            y: hourSize.height * (CGFloat(start) / 60 - CGFloat(hours.first!)) + hourBoxInset,
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
        let hours = endHour - startHour + 1
        
        return GeometryReader { geometry in
            content(
                HourConfig(
                    hours: startHour..<endHour+1,
                    hourSize: CGSize(width: geometry.size.width, height: geometry.size.height / CGFloat(hours)),
                    areaSize: CGSize(width: geometry.size.width, height: geometry.size.height)
                )
            )
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 1000.0, height: 800.0)
    }
}



private func formatDayTitle(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "ccc d"
    
    return formatter.string(from: date)
}

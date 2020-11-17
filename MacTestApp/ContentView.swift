//
//  ContentView.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 15.11.2020.
//

import SwiftUI

struct ContentView: View {
    @State private var days: [Day] = []
    
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


struct DayColumn: View {
    let events: [Event]
    
    var body: some View {
        HourlyColumn() { config in
            //ZStack {
                /*VStack(spacing: 0) {
                    ForEach(config.hours) { hour in
                        Text("\(hour).00")
                            .frame(maxWidth: .infinity)
                            .frame(height: config.hourSize.height)
                            .background(Color.blue.opacity(0.25))
                            .border(edges: [.top, .trailing], color: Color.gray)
                    }
                }*/
                ForEach(events) { event in
                    let frame = config.frameFor(start: event.startHour, end: event.endHour)
                    
                    Color(event.calendar.color).opacity(0.5)
                        .overlay(
                            //VStack() {
                                Text(event.title)
                            //}
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        )
                        .frame(frame)
                        //.background(Color.red.opacity(0.5))
                        .border(Color.gray)
                }
            //}
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
                        .padding(.trailing, 5)
                        .padding(.top, -3)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .frame(height: config.hourSize.height)
                        .background(Color.blue.opacity(0.25))
                }
            }
        }
    }
}

struct HourConfig {
    let hours: Range<Int>
    let hourSize: CGSize
    let areaSize: CGSize
    
    func frameFor(start: Int, end: Int) -> CGRect {
        CGRect(
            x: 0,
            y: hourSize.height * (CGFloat(start - hours.first!) + 0.5),
            width: hourSize.width,
            height: hourSize.height * CGFloat(end - start)
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

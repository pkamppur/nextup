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
            HourColumn()
                .frame(maxWidth: 70)
            ForEach(days) { day in
                HourStack(events: day.events)
            }
        }
        .background(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            EventService.instance.events { events in
                for day in events {
                    print("Day \(day.date), events: \(day.events)")
                }
                
                days = events
            }
        }
    }
}


struct HourStack: View {
    let events: [Event]
    
    var body: some View {
        HourStacks() { config in
            VStack(spacing: 0) {
                ForEach(config.hours) { hour in
                    Text("\(hour).00")
                        .frame(maxWidth: .infinity)
                        .frame(height: config.hourSize.height)
                        .background(Color.blue.opacity(0.25))
                        .border(edges: [.top, .trailing], color: Color.gray)
                }
            }
        }
    }
}


struct HourColumn: View {
    var body: some View {
        HourStacks() { config in
            ForEach(config.hours) { hour in
                Text("\(hour).00")
                    .font(.caption)
                    .padding(.trailing, 5)
                    .padding(.top, -3)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
    }
}

struct HourConfig {
    let hours: Range<Int>
    let hourSize: CGSize
    let areaSize: CGSize
}

struct HourStacks<Content: View>: View {
    private let startHour = 8
    private let endHour = 17
    let content: (HourConfig) -> Content
    
    var body: some View {
        let hours = endHour - startHour + 2 // Show one hour even if start==end, plus 1 hour spacing divided above and below
        
        return GeometryReader { geometry in
            ZStack {
                content(
                    HourConfig(
                        hours: startHour..<endHour+1,
                        hourSize: CGSize(width: geometry.size.width, height: geometry.size.height / CGFloat(hours)),
                        areaSize: CGSize(width: geometry.size.width, height: geometry.size.height)
                    )
                )
                Color.red.opacity(0.5)
                    .frame(
                        x: 0,
                        y: geometry.size.height / CGFloat(hours) * (10 - 8 + 0.5),
                        width: geometry.size.width,
                        height: geometry.size.height / CGFloat(hours) * 4.5
                    )
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 1000.0, height: 800.0)
    }
}

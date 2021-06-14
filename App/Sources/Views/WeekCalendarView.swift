//
//  WeekCalendarView.swift
//  NextUp
//
//  Created by Petteri Kamppuri on 23.11.2020.
//

import SwiftUI



let gridColor = Color(white: 0.89, opacity: 1)


struct WeekCalendarView: View {
    let now: Date
    let days: [Day]
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .trailing, spacing: 0) {
                HeaderText(text: weekNumber)
                HourHeaderColumn()
            }
            .frame(maxWidth: 70)
            
            ForEach(days) { day in
                VStack(spacing: 0) {
                    HeaderText(text: formatDayTitle(day.date))
                    DayColumn(now: now, date: day.date, events: displayEvents(from: day.events))
                }
            }
        }
        .background(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var weekNumber: String {
        guard let date = days.first?.date else { return "" }
        
        if date == Date.distantPast {
            return ""
        }
        
        return "W\(date.weekNumber())"
    }
}


struct HeaderText: View {
    let text: String
    
    var body: some View {
        Text(text)
            .padding([ .top ], 20)
            .padding([ .bottom ], 10)
            .font(.subheadline)
    }
}

struct DayColumn: View {
    let now: Date
    let date: Date
    let events: [DisplayEvent]
    
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
                .if(date.isToday()) {
                    $0
                        .border(width: 2, edges: [.leading, .trailing], color: Color.red.opacity(0.5))
                        .background(Color.red.opacity(0.04))
                }
                
                ForEach(events) { event in
                    let frame = config.frameFor(event)
                    let titleMaxHeight = CGFloat(event.maxTitleHeight) / 60 * config.hourSize.height
                    let showStartTime = event.maxTitleHeight >= 45

                    EventArea(event: event, titleMaxHeight: titleMaxHeight, showStartTime: showStartTime)
                        .frame(frame)
                        .if(date.isToday() && event.end <= now.minutesFromDayStart()) {
                            $0.opacity(0.25)
                        }
                }
                
                if date.isToday() {
                    Color.red.opacity(0.5)
                        .frame(config.frameFor(time: now, height: 2))
                }
            }
        }
        .if(!date.isToday() && date < now) {
            $0.opacity(0.5)
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


struct EventArea: View {
    let event: DisplayEvent
    let titleMaxHeight: CGFloat
    let showStartTime: Bool
    
    @ViewBuilder
    var backgroundView: some View {
        if event.isStriped {
            Stripes(config: stripeConfig())
        } else {
            Color(event.color.nsColor.lighter(by: 0.7))
        }
    }
    
    var body: some View {
        let eventColor = event.color.nsColor
        return backgroundView
            .opacity(0.7)
            .overlay(
                HStack(alignment: .top, spacing: 0) {
                    Color(eventColor)
                        .frame(width: 2)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        if showStartTime {
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
                    .frame(maxHeight: titleMaxHeight, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            )
            .cornerRadius(5)
    }
    
    private func stripeConfig() -> StripeConfig {
        StripeConfig(
            foreground: Color(white: 0.875),
            background: .white,
            lineWidth: 5,
            spacing: 1.5
        )
    }
}

struct HourConfig {
    let hours: Range<Int>
    let hourSize: CGSize
    let areaSize: CGSize
    private let hourBoxInset: CGFloat = 2
    
    func frameFor(_ event: DisplayEvent) -> CGRect {
        let indentationPerLevel: CGFloat = 5
        let indent = CGFloat(event.indentationLevel) * indentationPerLevel
        let columnWidth = hourSize.width / CGFloat(event.columnCount)
        
        let x = indent + columnWidth * CGFloat(event.columnPos)
        let width = columnWidth - hourBoxInset - indent
        
        if event.isAllDay {
            return CGRect(
                x: x,
                y: -hourSize.height + hourBoxInset,
                width: width,
                height: hourSize.height - hourBoxInset
            )
        }
        
        return CGRect(
            x: x,
            y: hourSize.height * (CGFloat(event.start) / 60 - CGFloat(hours.first!)) + hourBoxInset,
            width: width,
            height: hourSize.height * CGFloat(event.end - event.start) / 60 - hourBoxInset
        )
    }
    
    func frameFor(time: Date, height: CGFloat) -> CGRect {
        CGRect(
            x: 0,
            y: hourSize.height * (CGFloat(time.minutesFromDayStart()) / 60 - CGFloat(hours.first!)) + hourBoxInset,
            width: areaSize.width,
            height: height
        )
    }
}

struct HourlyColumn<Content: View>: View {
    private let startHour = 8
    private let endHour = 18
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



struct WeekCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        WeekCalendarView(now: Date(), days: sampleEvents())
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

private func formatDayTitle(_ date: Date) -> String {
    if date == Date.distantPast {
        return ""
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "ccc d"
    
    return formatter.string(from: date)
}

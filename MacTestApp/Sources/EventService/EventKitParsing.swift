//
//  EventKitParsing.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 17.11.2020.
//

import EventKit

extension Event {
    static func from(_ event: EKEvent) -> Event {
        print("*** Event \(event), status \(event.status.rawValue), availability \(event.availability.rawValue)")
        
        let status: Event.Status = {
            if event.status == .canceled {
                return .canceled
            }
            if event.status == .tentative {
                return .tentative
            }
            
            var participantStatus: Event.Status = .normal
            event.attendees?.forEach { participant in
                if participant.isCurrentUser {
                    print("    **** participant status \(participant.participantStatus.rawValue)")
                    
                    switch participant.participantStatus {
                        case .pending, .tentative:
                            participantStatus = .tentative
                        case .declined:
                            participantStatus = .canceled
                        case .accepted, .unknown, .delegated, .completed, .inProcess:
                            participantStatus = .normal
                        @unknown default:
                            participantStatus = .normal
                    }
                }
            }
            
            return participantStatus
        }()
        
        return Event(
            id: event.eventIdentifier,
            calendar: EventCalendar.from(event.calendar),
            title: event.title,
            startDate: event.startDate,
            endDate: event.endDate,
            status: status
        )
    }
}

extension EventCalendar {
    static func from(_ calendar: EKCalendar) -> EventCalendar {
        EventCalendar(
            name: calendar.title,
            color: CodableColor(cgColor: calendar.color.cgColor)
        )
    }
}

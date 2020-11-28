//
//  Model.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 17.11.2020.
//

import EventKit

typealias Minutes = Int

struct Event: Codable {
    let id: String
    let calendar: EventCalendar
    let title: String
    
    let startDate: Date
    let endDate: Date
    
    let status: Status
    
    enum Status: String, Codable {
        case normal
        case canceled
        case tentative
        /*
        static func from(_ status: EKEventStatus) -> Status {
            switch status {
                case .none, .confirmed:
                    return normal
                case .tentative:
                    return tentative
                case .canceled:
                    return canceled
                @unknown default:
                    return normal
            }
        }*/
    }
}

extension Event {
    var startTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: startDate)
    }
    
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

extension Event: Identifiable {}

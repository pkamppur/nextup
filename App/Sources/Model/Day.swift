//
//  Day.swift
//  NextUp
//
//  Created by Petteri Kamppuri on 23.11.2020.
//

import Foundation

struct Day: Codable {
    let date: Date
    let events: [Event]
}

extension Day: Identifiable {
    var id: Date { date }
}

extension Day {
    func json() -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        return try! encoder.encode(self)
    }
    
    static func fromJson(_ data: Data) -> Self {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try! decoder.decode(Self.self, from: data)
    }
}

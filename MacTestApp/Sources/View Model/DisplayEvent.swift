//
//  DisplayEvent.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 23.11.2020.
//

import Foundation

struct DisplayEvent: Identifiable {
    let id: String
    let title: String
    let color: CodableColor
    let startTimeString: String
    let start: Minutes
    let end: Minutes
    let indentationLevel: Int
    let columnPos: Int
    let columnCount: Int
    
    var duration: Minutes {
        end - start
    }
}

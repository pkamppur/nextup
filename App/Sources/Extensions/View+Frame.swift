//
//  View+Frame.swift
//  NextUp
//
//  Created by Petteri Kamppuri on 17.11.2020.
//

import SwiftUI

extension View {
    func frame(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> some View {
        self
            .frame(width: width, height: height)
            .position(x: x + width / 2, y: y + height / 2)
    }

    func frame(_ frame: CGRect) -> some View {
        self
            .frame(
                x: frame.origin.x,
                y: frame.origin.y,
                width: frame.size.width,
                height: frame.size.height
            )
    }
}


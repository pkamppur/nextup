//
//  NSColor+extensions.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 18.11.2020.
//

#if os(OSX)

import AppKit

extension NSColor {
    func mix(with color: NSColor, amount: CGFloat) -> Self {
        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        var alpha1: CGFloat = 0
        
        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        var alpha2: CGFloat = 0
        
        usingColorSpace(NSColorSpace.extendedSRGB)!.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color.usingColorSpace(NSColorSpace.extendedSRGB)!.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        return Self(
            red: red1 * CGFloat(1.0 - amount) + red2 * amount,
            green: green1 * CGFloat(1.0 - amount) + green2 * amount,
            blue: blue1 * CGFloat(1.0 - amount) + blue2 * amount,
            alpha: alpha1
        )
    }
    
    func lighter(by amount: CGFloat = 0.2) -> Self { mix(with: NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 1), amount: amount) }
    func darker(by amount: CGFloat = 0.2) -> Self { mix(with: NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 1), amount: amount) }
}

#endif

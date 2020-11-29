//
//  CodableColor.swift
//  NextUp
//
//  Created by Petteri Kamppuri on 23.11.2020.
//

#if os(OSX)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

struct CodableColor: Codable {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
    
    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    init(white: CGFloat, alpha: CGFloat) {
        self.red = white
        self.green = white
        self.blue = white
        self.alpha = alpha
    }
    
    init(cgColor: CGColor) {
        let rgbColor = cgColor.converted(
            to: CGColorSpace(name: CGColorSpace.sRGB)!,
            intent: CGColorRenderingIntent.defaultIntent,
            options: nil
        )!
        
        let components = rgbColor.components!
        
        red = components[0]
        green = components[1]
        blue = components[2]
        alpha = components[3]
    }
    
    #if os(OSX)
    var nsColor: NSColor {
        return NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    init(nsColor: NSColor) {
        red = 0
        green = 0
        blue = 0
        alpha = 0
        nsColor.usingColorSpace(NSColorSpace.extendedSRGB)!.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
    #elseif os(iOS)
    var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    init(uiColor: UIColor) {
        red = 0
        green = 0
        blue = 0
        alpha = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
    #endif
}


//
//  Stripes.swift
//  NextUp
//
//  Created by Petteri Kamppuri on 28.11.2020.
//

import SwiftUI

struct Stripes: View {
    let config: StripeConfig
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let lineWidth = config.lineWidth
                let spacing = config.spacing
                
                // Source: https://stackoverflow.com/a/35820837
                let renderRect = CGRect(x: 0, y: 0, width: width, height: height).insetBy(dx: -lineWidth * 0.5, dy: -lineWidth * 0.5)
                
                // the total distance to travel when looping (each line starts at a point that
                // starts at (0,0) and ends up at (width, height)).
                let totalDistance = renderRect.size.width + renderRect.size.height
                
                // loop through distances in the range 0 ... totalDistance
                for distance in stride(from: 0, through: totalDistance,
                                       // divide by cos(45º) to convert from diagonal length
                                       by: (spacing + lineWidth) / cos(.pi / 4)) {
                    // the start of one of the stripes
                    path.move(to: CGPoint(
                        // x-coordinate based on whether the distance is less than the width of the
                        // rect (it should be fixed if it is above, and moving if it is below)
                        x: distance < renderRect.width ?
                            renderRect.origin.x + distance :
                            renderRect.origin.x + renderRect.width,
                        
                        // y-coordinate based on whether the distance is less than the width of the
                        // rect (it should be moving if it is above, and fixed if below)
                        y: distance < renderRect.width ?
                            renderRect.origin.y :
                            distance - (renderRect.width - renderRect.origin.x)
                    ))
                    
                    // the end of one of the stripes
                    path.addLine(to: CGPoint(
                        // x-coordinate based on whether the distance is less than the height of
                        // the rect (it should be moving if it is above, and fixed if it is below)
                        x: distance < renderRect.height ?
                            renderRect.origin.x :
                            distance - (renderRect.height - renderRect.origin.y),
                        
                        // y-coordinate based on whether the distance is less than the height of
                        // the rect (it should be fixed if it is above, and moving if it is below)
                        y: distance < renderRect.height ?
                            renderRect.origin.y + distance :
                            renderRect.origin.y + renderRect.height
                    ))
                }
            }
            .stroke(config.foreground, lineWidth: config.lineWidth)
            .background(config.background)
        }
    }
}


struct StripeConfig {
    let foreground: Color
    let background: Color
    let lineWidth: CGFloat
    let spacing: CGFloat
}

//
//  View+Conditional.swift
//  MacTestApp
//
//  Created by Petteri Kamppuri on 18.11.2020.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

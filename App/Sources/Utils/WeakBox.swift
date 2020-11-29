//
//  WeakBox.swift
//  NextUp
//
//  Created by Petteri Kamppuri on 23.11.2020.
//

import Foundation

final class WeakBox<T: AnyObject> {
    weak var value: T?
    init(_ value: T) {
        self.value = value
    }
}

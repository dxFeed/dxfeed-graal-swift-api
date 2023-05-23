//
//  WeakBox.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 23.05.23.
//

import Foundation

class WeakBox<T: AnyObject> {
    weak var value: T?
    init (value: T) {
        self.value = value
    }
}

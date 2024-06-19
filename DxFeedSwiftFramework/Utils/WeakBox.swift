//
//  WeakBox.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 23.05.23.
//

import Foundation

class WeakBox<T> {
    private weak var _value: AnyObject?
    var value: T? {
        return _value as? T
    }
    init(value: T) {
        self._value = value as AnyObject
    }
}

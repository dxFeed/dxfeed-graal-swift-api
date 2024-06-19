//
//  ListNative.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 31.05.23.
//

import Foundation

class ListNative<T> {
    let size: Int32
    let elements: UnsafeMutablePointer<UnsafeMutablePointer<T>?>
    let deallocEachElement: Bool
    deinit {
        var iterator = elements
        for _ in 0..<size {
            if deallocEachElement {
                iterator.pointee?.deinitialize(count: 1)
                iterator.pointee?.deallocate()
            }
            iterator.deinitialize(count: 1)
            iterator = iterator.successor()
        }
        elements.deinitialize(count: Int(size))
        elements.deallocate()
    }

    init(elements: [T]) {
        self.deallocEachElement = true
        self.size = Int32(elements.count)
        let classes = UnsafeMutablePointer<UnsafeMutablePointer<T>?>
            .allocate(capacity: elements.count)
        var iterator = classes
        for code in elements {
            let value: UnsafeMutablePointer<T>? =
            UnsafeMutablePointer<T>.allocate(capacity: 1)
            value?.initialize(to: code)
            iterator.initialize(to: value)
            iterator = iterator.successor()
        }
        self.elements = classes
    }

    init(pointers: [UnsafeMutablePointer<T>?]) {
        self.deallocEachElement = false
        self.size = Int32(pointers.count)
        let classes = UnsafeMutablePointer<UnsafeMutablePointer<T>?>
            .allocate(capacity: pointers.count)
        var iterator = classes
        for code in pointers {
            iterator.initialize(to: code)
            iterator = iterator.successor()
        }
        self.elements = classes
    }
}

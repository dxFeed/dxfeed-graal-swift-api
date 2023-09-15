//
//  ConcurrentArray.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 30.05.23.
//

import Foundation

class ConcurrentArray<T>: CustomStringConvertible {
    private var array: [T]
    private let accessQueue = DispatchQueue(label: "com.dxfeed.array_queue", attributes: .concurrent)

    public init(_ array: [T] = []) {
        self.array = array
    }

    public var description: String {
        return reader { $0.description }
    }

    public subscript(index: Int) -> T {
        get { reader { $0[index] } }
        set { writer { $0[index] = newValue } }
    }

    public var count: Int {
        reader { $0.count }
    }

    public func append(newElement: T) {
        writer { $0.append(newElement) }
    }

    public func append(newElements: [T]) {
        writer { $0.append(contentsOf: newElements) }
    }

    public func removeAll() {
        writer { $0.removeAll() }
    }

    public func removeAll(where shouldBeRemoved: @escaping (T) throws -> Bool) rethrows {
        writer { try? $0.removeAll(where: shouldBeRemoved) }
    }

    public func reader<U>(_ block: ([T]) throws -> U) rethrows -> U {
        try accessQueue.sync { try block(array) }
    }

    public func writer(_ block: @escaping (inout [T]) -> Void) {
        accessQueue.async(flags: .barrier) { block(&self.array) }
    }
}

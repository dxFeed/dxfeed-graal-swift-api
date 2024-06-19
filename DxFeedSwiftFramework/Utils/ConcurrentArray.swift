//
//  ConcurrentArray.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 30.05.23.
//

import Foundation

class ConcurrentArray<T>: CustomStringConvertible {
    private var array: [T]
    private let accessQueue = DispatchQueue(label: "com.dxfeed.array_queue", attributes: .concurrent)

    init(_ array: [T] = []) {
        self.array = array
    }

    var description: String {
        return reader { $0.description }
    }

    subscript(index: Int) -> T {
        get { reader { $0[index] } }
        set { writer { $0[index] = newValue } }
    }

    var count: Int {
        reader { $0.count }
    }

    func append(newElement: T) {
        writer { $0.append(newElement) }
    }

    func removeAll(where shouldBeRemoved: @escaping (T) throws -> Bool) rethrows {
        writer { try? $0.removeAll(where: shouldBeRemoved) }
    }

    func reader<U>(_ block: ([T]) throws -> U) rethrows -> U {
        try accessQueue.sync { try block(array) }
    }

    func writer(_ block: @escaping (inout [T]) -> Void) {
        accessQueue.async(flags: .barrier) { block(&self.array) }
    }
}

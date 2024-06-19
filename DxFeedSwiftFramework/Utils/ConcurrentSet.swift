//
//  ConcurrentSet.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 30.05.23.
//

import Foundation

class ConcurrentSet<T>: CustomStringConvertible where T: Hashable {
    private var set = Set<T>()
    private let accessQueue = DispatchQueue(label: "com.dxfeed.set_queue", attributes: .concurrent)

    init(_ set: Set<T> = Set<T>()) {
        self.set = set
    }

    var description: String {
        return reader { $0.description }
    }

    var count: Int {
        reader { $0.count }
    }

    func insert(_ newMember: T) {
        writer { $0.insert(newMember) }
    }

    func remove(_ member: T) {
        writer { $0.remove(member) }
    }

    func remove(at position: Set<T>.Index) {
        writer { $0.remove(at: position) }
    }

    func reader<U>(_ block: (Set<T>) throws -> U) rethrows -> U {
        try accessQueue.sync { try block(set) }
    }

    func writer(_ block: @escaping (inout Set<T>) -> Void) {
        accessQueue.async(flags: .barrier) { block(&self.set) }
    }
}

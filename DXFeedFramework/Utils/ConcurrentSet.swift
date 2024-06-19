//
//  ConcurrentSet.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 30.05.23.
//

import Foundation

public class ConcurrentSet<T>: CustomStringConvertible where T: Hashable {
    private var set = Set<T>()
    private let accessQueue = DispatchQueue(label: "com.dxfeed.set_queue", attributes: .concurrent)

    public init(_ set: Set<T> = Set<T>()) {
        self.set = set
    }

    public var description: String {
        return reader { $0.description }
    }

    public var count: Int {
        reader { $0.count }
    }

    public func insert(_ newMember: T) {
        let weakValue = WeakBox(value: newMember)
        writer { $0.insert(newMember) }
    }

    public func remove(_ member: T) {
        writer { $0.remove(member) }
    }

    public func remove(at position: Set<T>.Index) {
        writer { $0.remove(at: position) }
    }
    public func removeAll() {
        writer { $0.removeAll() }
    }

    public func reader<U>(_ block: (Set<T>) throws -> U) rethrows -> U {
        try accessQueue.sync { try block(set) }
    }

    public func writer(_ block: @escaping (inout Set<T>) -> Void) {
        accessQueue.async(flags: .barrier) { block(&self.set) }
    }
}

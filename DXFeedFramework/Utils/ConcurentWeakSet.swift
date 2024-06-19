//
//  ConcurentWeakSet.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 29.09.23.
//

import Foundation

public class ConcurrentWeakSet<T: AnyObject> {
    private var set: NSHashTable<T> = .weakObjects()
    private let accessQueue = DispatchQueue(label: "com.dxfeed.set_nshashtable", attributes: .concurrent)

    public var count: Int {
        reader { $0.count }
    }

    public func insert(_ newMember: T) {
        writer { $0.add(newMember) }
    }

    public func remove(_ member: T) {
        writer { $0.remove(member) }
    }

    public func removeAll() {
        writer { $0.removeAllObjects() }
    }

    public func reader<U>(_ block: (NSHashTable<T>) throws -> U) rethrows -> U {
        try accessQueue.sync { try block(set) }
    }

    public func writer(_ block: @escaping (inout NSHashTable<T>) -> Void) {
        accessQueue.async(flags: .barrier) { block(&self.set) }
    }
}

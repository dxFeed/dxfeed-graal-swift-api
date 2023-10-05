//
//  ConcurrentWeakHashTable.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 29.09.23.
//

import Foundation

public class ConcurrentWeakHashTable<T> {
    internal var set: NSHashTable<AnyObject> = .weakObjects()
    private let accessQueue = DispatchQueue(label: "com.dxfeed.set_nshashtable", attributes: .concurrent)

    public var count: Int {
        reader { $0.count }
    }

    public func insert(_ newMember: T) {
        writer {
            $0.add(newMember as AnyObject)
        }
    }

    public func remove(_ member: T) {
        writer { $0.remove(member as AnyObject) }
    }

    public func removeAll() {
        writer { $0.removeAllObjects() }
    }

    public func reader<U>(_ block: (NSHashTable<AnyObject>) throws -> U) rethrows -> U {
        try accessQueue.sync { try block(set) }
    }

    public func writer(_ block: @escaping (inout NSHashTable<AnyObject>) -> Void) {
        accessQueue.async(flags: .barrier) { block(&self.set) }
    }
}

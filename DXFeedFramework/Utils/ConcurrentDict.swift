//
//  ConcurrentDict.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 08.08.23.
//

import Foundation

class ConcurrentDict<Key: Hashable, Value>: CustomStringConvertible {
    private var set = [Key: Value]()
    private let accessQueue = DispatchQueue(label: "com.dxfeed.set_queue", attributes: .concurrent)

    public init(_ set: [Key: Value] = [Key: Value]()) {
        self.set = set
    }

    public var description: String {
        return reader { $0.description }
    }

    public var count: Int {
        reader { $0.count }
    }

    subscript(key: Key) -> Value? {
        get {
            reader {
                $0[key]
            }
        }
        set(newValue) {
            writer {
                $0[key] = newValue
            }
        }
    }

    subscript(index: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
        reader {
            $0[index]
        }
    }

    func first(where predicate: ((key: Key, value: Value)) throws -> Bool) rethrows -> (key: Key, value: Value)? {
        return try reader {
            try $0.first(where: predicate)
        }
    }

    func removeValue(forKey key: Key) {
        writer {
            $0.removeValue(forKey: key)
        }
    }

    public func removeAll() {
        writer { $0.removeAll() }
    }

    public func tryInsert(key: Key, value: Value) -> Bool {
        return accessQueue.sync {
            return set.updateValue(value, forKey: key) == nil
        }
    }

    public func tryGetValue(key: Key, generator: () throws -> Value) throws -> Value {
        return try accessQueue.sync {
            if let existingValue = set[key] {
                return existingValue
            }
            let newValue = try generator()
            set[key] = newValue
            return newValue
        }
    }

    public func reader<U>(_ block: ([Key: Value]) throws -> U) rethrows -> U {
        try accessQueue.sync { try block(set) }
    }

    public func writer(_ block: @escaping (inout [Key: Value]) -> Void) {
        accessQueue.async(flags: .barrier) { block(&self.set) }
    }
}

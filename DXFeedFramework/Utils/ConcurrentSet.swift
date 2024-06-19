//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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

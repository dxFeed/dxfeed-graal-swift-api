//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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

    public func member(_ newMember: T) -> Bool {
        return reader {
            return $0.member(newMember as AnyObject) != nil
        }
    }

    public func reader<U>(_ block: (NSHashTable<AnyObject>) throws -> U) rethrows -> U {
        try accessQueue.sync { try block(set) }
    }

    public func writer(_ block: @escaping (inout NSHashTable<AnyObject>) -> Void) {
        accessQueue.async(flags: .barrier) { block(&self.set) }
    }
}

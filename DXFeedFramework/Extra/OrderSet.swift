//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

class OrderSet {
    private var lock = pthread_rwlock_t()
    private var snapshot = NSMutableArray()
    private let comparator: (Order, Order) -> ComparisonResult
    /// add using comparator in orders
    private var orders = NSMutableOrderedSet()
    var depthLimit: Int = 0 {
        willSet {
            if newValue != depthLimit {
                isChanged = true
            }
        }
    }

    private(set) var isChanged: Bool = false

    deinit {
         pthread_rwlock_destroy(&lock)
     }

    init(comparator: @escaping (Order, Order) -> ComparisonResult) {
        pthread_rwlock_init(&lock, nil)
        self.comparator = comparator
    }

    func clearBySource(_ source: IndexedEventSource) {
        pthread_rwlock_wrlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }
        let predicate = NSPredicate { order, _ in
            (order as? Order)?.eventSource == source
        }
        isChanged = orders.removeIf(using: predicate)
    }

    func remove(_ order: Order) {
        pthread_rwlock_wrlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }
        if orders.contains(order) {
            orders.remove(order)
            markAsChangedIfNeeded(order)
        }
    }

    func markAsChangedIfNeeded(_ order: Order) {
        if isChanged {
            return
        }
        if isDepthLimitUnbounded() || isSizeWithinDepthLimit() || isOrderWithinDepthLimit(order) {
            isChanged = true
        }
    }

    func add(_ order: Order) {
        pthread_rwlock_wrlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }
        if !orders.contains(order) {
            orders.add(order)
            markAsChangedIfNeeded(order)
        }
    }

    func isDepthLimitUnbounded() -> Bool {
        return depthLimit <= 0 || depthLimit == .max
    }

    func isSizeWithinDepthLimit() -> Bool {
        return orders.count <= depthLimit
    }

    func isOrderWithinDepthLimit(_ order: Order) -> Bool {
        if snapshot.count == 0 {
            return true
        }
        if let last = snapshot.lastObject as? Order {
            let compareResult = comparator(last, order)
            return compareResult == .orderedSame || compareResult == .orderedDescending
        }
        return false
    }

    func toList() -> [Order] {
        if isChanged {
            updateSnapshot()
        }
        if let list = snapshot as? [Order] {
            return list
        } else {
            fatalError("failed casting to array")
        }
    }

    func updateSnapshot() {
        pthread_rwlock_rdlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }

        isChanged = false
        snapshot.removeAllObjects()
        let limit = isDepthLimitUnbounded() ? .max : depthLimit
        let sorted = orders.sortedArray { obj1, obj2 in
            if let order1 = obj1 as? Order,
               let order2 = obj2 as? Order {
                return self.comparator(order1, order2)
            }
            return .orderedSame
        }
        for (index, element) in sorted.enumerated() where index < limit {
            snapshot.add(element)
        }
    }
}

//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

class OrderSet {
    var lock = NSLock()

    var snapshot = NSMutableArray()
    let comparator: (Order, Order) -> ComparisonResult
    /// add using comparator in orders
    var orders = NSMutableOrderedSet()
    var depthLimit: Int = 0 {
        willSet {
            if newValue != depthLimit {
                _isChanged = true
            }
        }
    }

    private var _isChanged: Bool = false

    init(comparator: @escaping (Order, Order) -> ComparisonResult) {

        self.comparator = comparator
    }

    func isChanged() -> Bool {
        return _isChanged
    }

    func clearBySource(_ source: IndexedEventSource) {
        lock.lock()
        defer {
            lock.unlock()
        }
        let predicate = NSPredicate { order, _ in
            (order as? Order)?.eventSource == source
        }
        _isChanged = orders.removeIf(using: predicate)
    }

    func remove(_ order: Order) {
        lock.lock()
        defer {
            lock.unlock()
        }
        if orders.contains(order) {
            orders.remove(order)
            markAsChangedIfNeeded(order)
        }
    }

    func markAsChangedIfNeeded(_ order: Order) {
        if _isChanged {
            return
        }
        if isDepthLimitUnbounded() || isSizeWithinDepthLimit() || isOrderWithinDepthLimit(order) {
            _isChanged = true
        }
    }

    func add(_ order: Order) {
        lock.lock()
        defer {
            lock.unlock()
        }
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
        if _isChanged {
            updateSnapshot()
        }
        if let list = snapshot as? [Order] {
            return list
        } else {
            fatalError("failed casting to array")
        }
    }

    func updateSnapshot() {
        lock.lock()
        defer {
            lock.unlock()
        }

        _isChanged = false
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

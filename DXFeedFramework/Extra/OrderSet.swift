//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

class OrderSet {
    var snapshot = Array<Order>()
    let comparator: (Order, Order) -> ComparisonResult
    ///add using comparator in orders
    let orders = NSMutableOrderedSet()
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
        let predicate = NSPredicate { order, _ in
            (order as? Order)?.eventSource == source
        }
        _isChanged = orders.removeIf(using: predicate)
    }

    func remove(_ order: Order) {
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
        if (snapshot.isEmpty) {
            return true
        }
        if let last = snapshot.last {
            let compareResult = comparator(last, order)
            return compareResult == .orderedSame || compareResult == .orderedDescending
        }
        return false
    }

    func toList() -> [Order] {
        if _isChanged {
            updateSnapshot()
        }
        return Array(snapshot)
    }

    func updateSnapshot() {
        _isChanged = false
        snapshot.removeAll()
        let limit = isDepthLimitUnbounded() ? .max : depthLimit

        for (index, element) in orders.enumerated() {
            if let order = element as? Order {
                if index < limit {
                    snapshot.append(order)
                }
            }
        }
    }
}

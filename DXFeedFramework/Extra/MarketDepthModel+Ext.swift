//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

extension MarketDepthModel {
    static let orderComparator: (Order, Order) -> ComparisonResult = { order1, order2 in
        let ind1 = order1.scope == Scope.order
        let ind2 = order2.scope == Scope.order
        if ind1 && ind2 {
            // Both orders are individual orders
            var compare = order1.timeSequence.compare(order2.timeSequence) // asc
            if compare != .orderedSame {
                return compare
            }
            compare = order1.index.compare(order2.index) // asc
            return compare
        } else if ind1 {
            // First order is individual, second is not
            return .orderedDescending
        } else if ind2 {
            // Second order is individual, first is not
            return .orderedAscending
        } else {
            // Both orders are non-individual orders
            var compare = order2.size.compare(order1.size) // desc
            if compare != .orderedSame {
                return compare
            }
            compare = order1.timeSequence.compare(order2.timeSequence) // asc
            if compare != .orderedSame {
                return compare
            }
            compare = ComparisonResult(rawValue: order1.scope.code - order2.scope.code)! // asc
            if compare != .orderedSame {
                return compare
            }
            compare = ComparisonResult(rawValue: order1.getExchangeCode() - order2.getExchangeCode())! // asc
            if compare != .orderedSame {
                return compare
            }
            if let o1marketMaker = order1.marketMaker, let o2marketMaker = order2.marketMaker {
                let compare = o1marketMaker.compare(o2marketMaker)
                if compare != .orderedSame {
                    return compare
                }
            }
            compare = order1.index.compare(order2.index) // asc
            return compare
        }
    }

    static let buyComparator: (Order, Order) -> ComparisonResult = { order1, order2 in
        order1.price < order2.price ? .orderedDescending :
        (order1.price > order2.price ? .orderedAscending : orderComparator(order1, order2))
    }

    static let sellComparator: (Order, Order) -> ComparisonResult = { order1, order2 in
        order1.price < order2.price ? .orderedAscending :
        (order1.price > order2.price ? .orderedDescending : orderComparator(order1, order2))
    }
}

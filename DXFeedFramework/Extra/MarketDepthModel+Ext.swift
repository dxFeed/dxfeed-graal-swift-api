//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

extension MarketDepthModel {
    static let orderComparator: (Order, Order) -> ComparisonResult = { o1, o2 in
        let ind1 = o1.scope == Scope.order
        let ind2 = o2.scope == Scope.order
        if ind1 && ind2 {
            // Both orders are individual orders
            var compare = o1.timeSequence.compare(o2.timeSequence) // asc
            if compare != .orderedSame {
                return compare
            }
            compare = o1.index.compare(o2.index) // asc
            return compare
        } else if ind1 {
            // First order is individual, second is not
            return .orderedDescending
        } else if ind2 {
            // Second order is individual, first is not
            return .orderedAscending
        } else {
            // Both orders are non-individual orders
            var compare = o2.size.compare(o1.size) // desc
            if compare != .orderedSame {
                return compare
            }
            compare = o1.timeSequence.compare(o2.timeSequence) // asc
            if compare != .orderedSame {
                return compare
            }
            compare = ComparisonResult(rawValue: o1.scope.code - o2.scope.code)! // asc
            if compare != .orderedSame {
                return compare
            }
            compare = ComparisonResult(rawValue: o1.getExchangeCode() - o2.getExchangeCode())! // asc
            if compare != .orderedSame {
                return compare
            }
            if let o1marketMaker = o1.marketMaker, let o2marketMaker = o2.marketMaker {
                let compare = o1marketMaker.compare(o2marketMaker)
                if compare != .orderedSame {
                    return compare
                }
            }
            compare = o1.index.compare(o2.index) // asc
            return compare
        }
    }

    static let buyComparator: (Order, Order) -> ComparisonResult = { o1, o2 in
        o1.price < o2.price ? .orderedDescending :
        (o1.price > o2.price ? .orderedAscending : orderComparator(o1, o2))
    }

    static let sellComparator: (Order, Order) -> ComparisonResult = { o1, o2 in
        o1.price < o2.price ? .orderedAscending :
        (o1.price > o2.price ? .orderedDescending : orderComparator(o1, o2))
    }
}

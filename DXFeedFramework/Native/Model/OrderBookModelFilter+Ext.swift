//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

extension OrderBookModelFilter {
    func toNative() -> dxfg_order_book_model_filter_t {
        switch self {
        case .composite:
            return COMPOSITE
        case .regional:
            return REGIONAL
        case .aggregate:
            return AGGREGATE
        case .order:
            return ORDER
        case .compositeRegional:
            return COMPOSITE_REGIONAL
        case .compositeRegionalAgregate:
            return COMPOSITE_REGIONAL_AGGREGATE
        case .all:
            return ALL
        }
    }

    static func fromNative(native: dxfg_order_book_model_filter_t) -> OrderBookModelFilter {
        switch native {
        case COMPOSITE:
            return .composite
        case REGIONAL:
            return .regional
        case AGGREGATE:
            return .aggregate
        case ORDER:
            return .order
        case COMPOSITE_REGIONAL:
            return .compositeRegional
        case COMPOSITE_REGIONAL_AGGREGATE:
            return .compositeRegionalAgregate
        case ALL:
            return .all
        default:
            fatalError("Try to convert OrderBookModelFilter with wrong value \(native)")
        }
    }
}

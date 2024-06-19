//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

extension Greeks {
    convenience init(native: dxfg_greeks_t) {
        self.init(String(pointee: native.market_event.event_symbol))
        self.eventTime = native.market_event.event_time
        self.eventFlags = native.event_flags
        self.index = native.index
        self.price = native.price
        self.volatility = native.volatility
        self.delta = native.delta
        self.gamma = native.gamma
        self.theta = native.theta
        self.rho = native.rho
        self.vega = native.vega
    }
}

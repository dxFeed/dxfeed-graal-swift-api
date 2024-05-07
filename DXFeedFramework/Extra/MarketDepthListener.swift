//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

class OrderBook {
    let buyOrders: [Order]
    let sellOrders: [Order]

    init(buyOrders: [Order], sellOrders: [Order]) {
        self.buyOrders = buyOrders
        self.sellOrders = sellOrders
    }
}

protocol MarketDepthListener: AnyObject {
    func modelChanged(changes: OrderBook)
}

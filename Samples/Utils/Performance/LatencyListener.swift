//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import DXFeedFramework

class LatencyEventListener: AbstractEventListener {
    private let diagnostic = LatencyDiagnostic()

    override func handleEvents(_ events: [MarketEvent]) {
        let currentTime = Int64(Date().timeIntervalSince1970 * 1_000)
        events.forEach { tsEvent in
            switch tsEvent.type {
            case .quote:
                let quote = tsEvent.quote
                let delta = currentTime - quote.time
                diagnostic.addSymbol(tsEvent.eventSymbol)
                diagnostic.addDeltas(delta)
            case .timeAndSale:
                let timeAndSale = tsEvent.timeAndSale
                if timeAndSale.isNew && timeAndSale.isValidTick {
                    let delta = currentTime - timeAndSale.time
                    diagnostic.addSymbol(tsEvent.eventSymbol)
                    diagnostic.addDeltas(delta)
                }
            case .trade:
                let trade = tsEvent.trade
                let delta = currentTime - trade.time
                diagnostic.addSymbol(tsEvent.eventSymbol)
                diagnostic.addDeltas(delta)
            default: break
            }
        }
    }

    func metrics() -> LatencyMetrics {
        return diagnostic.getMetrics()
    }

    func cleanTime() {
        diagnostic.cleanTime()
    }
}

//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import SwiftUI

@main
struct DXFeedCandleChartMacApp: App {
    let symbol = "AAPL"
    var body: some Scene {
        WindowGroup {
            CandleChart(symbol: symbol,
                        type: .week,
                        endpoint: nil,
                        ipfAddress: "https://demo:demo@tools.dxfeed.com/ipf?SYMBOL=")
            .navigationTitle("CandleChart: \(symbol)")
        }
        .defaultSize(width: 800, height: 800)
    }
}

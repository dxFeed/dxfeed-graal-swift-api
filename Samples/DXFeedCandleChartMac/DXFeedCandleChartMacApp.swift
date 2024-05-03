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
            CandleStickChart(symbol: symbol, 
                             type: .week,
                             date: Calendar.current.date(byAdding: .year, value: -4, to: Date()))
            .navigationTitle("CandleChart: \(symbol)")
        }
        .defaultSize(width: 800, height: 800)
    }
}

//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import DXFeedFramework

class PerfTestEventListener: AbstractEventListener {
    private let diagnostic = PerfDiagnostic()
    override func handleEvents(_ events: [MarketEvent]) {
        let count = events.count
        diagnostic.updateCounters(Int64(count))
    }

    func metrics() -> PerformanceMetrics {
        return diagnostic.getMetrics()
    }

    func updateCpuUsage() {
        diagnostic.updateCpuUsage()
    }

    func cleanTime() {
        diagnostic.cleanTime()
    }
}

//
//  PerfTestEventListener.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 04.10.23.
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

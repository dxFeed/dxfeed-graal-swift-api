//
//  EventListener.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 21.09.23.
//

import Foundation
import DXFeedFramework


class LatencyEventListener: EventListener {
    let diagnostic = LatencyDiagnostic()

    override func handleEvents(_ events: [MarketEvent]) {
        let currentTime = Int64(Date().timeIntervalSince1970 * 1_000)
        var deltas = [Int64]()
        events.forEach { tsEvent in
            switch tsEvent.type {
            case .quote:
                let quote = tsEvent.quote
                let delta = currentTime - quote.time
                diagnostic.addSymbol(tsEvent.eventSymbol)
                diagnostic.addDeltas(delta)
            case .timeAndSale:
                let timeAndSale = tsEvent.timeAndSale
                let delta = currentTime - timeAndSale.time
                diagnostic.addSymbol(tsEvent.eventSymbol)
                diagnostic.addDeltas(delta)
            case .trade:
                let trade = tsEvent.trade
                let delta = currentTime - trade.time
                diagnostic.addSymbol(tsEvent.eventSymbol)
                diagnostic.addDeltas(delta)
            default: break
            }
        }
    }
}

class ConnectEventListener: EventListener {
    override func handleEvents(_ events: [MarketEvent]) {
        events.forEach { event in
            print(event)
        }
    }
}

class PerfTestEventListener: EventListener {
    let diagnostic = PerfDiagnostic()
    override func handleEvents(_ events: [MarketEvent]) {
        let count = events.count
        diagnostic.updateCounters(Int64(count))
    }
}

class EventListener: DXEventListener, Hashable {
    lazy var name = {
        stringReference(self)
    }()

    func receiveEvents(_ events: [DXFeedFramework.MarketEvent]) {
        handleEvents(events)
    }

    static func == (lhs: EventListener, rhs: EventListener) -> Bool {
        return lhs === rhs || lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    func handleEvents(_ events: [DXFeedFramework.MarketEvent]) {
        fatalError("Please, override this method")
    }
}

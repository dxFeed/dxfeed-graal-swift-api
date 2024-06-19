//
//  EventListener.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 21.09.23.
//

import Foundation
import DXFeedFramework

class ConnectEventListener: EventListener {
    override func handleEvents(_ events: [MarketEvent]) {
        events.forEach { event in
            print(event)
        }
    }
}

class PerfTestEventListener: EventListener {
    let diagnostic = Diagnostic()
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

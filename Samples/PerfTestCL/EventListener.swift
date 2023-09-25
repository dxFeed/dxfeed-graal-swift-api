//
//  EventListener.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 21.09.23.
//

import Foundation
import DXFeedFramework

class EventListener: DXEventListener, Hashable {
    let diagnostic = Diagnostic()

    let name: String
    func receiveEvents(_ events: [DXFeedFramework.MarketEvent]) {
        let count = events.count
        diagnostic.updateCounters(Int64(count))
    }

    init(name: String) {
        self.name = name
    }
    static func == (lhs: EventListener, rhs: EventListener) -> Bool {
        return lhs === rhs || lhs.name == rhs.name
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

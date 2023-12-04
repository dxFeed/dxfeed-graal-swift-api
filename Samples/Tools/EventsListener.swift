//
//  EventsListener.swift
//  Tools
//
//  Created by Aleksey Kosylo on 04.12.23.
//

import Foundation
import DXFeedFramework

class EventListener: DXEventListener, Hashable {

    let callback: ([MarketEvent]) -> Void

    init(callback: @escaping ([MarketEvent]) -> Void) {
        self.callback = callback
    }

    func receiveEvents(_ events: [DXFeedFramework.MarketEvent]) {
        callback(events)
    }

    static func == (lhs: EventListener, rhs: EventListener) -> Bool {
        return lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(stringReference(self))
    }
}

//
//  EventListener.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 21.09.23.
//

import Foundation
import DXFeedFramework

class Counter {
    private (set) var value: Int64 = 0
    func add (_ amount: Int64) {
        OSAtomicAdd64(amount, &value)
    }
}

class EventListener: DXEventListener, Hashable {
    let name: String
    var counter = Counter()
    var counterListener = Counter()
    func receiveEvents(_ events: [DXFeedFramework.MarketEvent]) {
        let count = events.count
        counterListener.add(1)
        counter.add(Int64(count))
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

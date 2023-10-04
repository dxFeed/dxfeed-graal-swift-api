//
//  AbstractEventListener.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 04.10.23.
//

import Foundation
import DXFeedFramework

class AbstractEventListener: DXEventListener, Hashable {
    lazy var name = {
        stringReference(self)
    }()

    func receiveEvents(_ events: [DXFeedFramework.MarketEvent]) {
        handleEvents(events)
    }

    static func == (lhs: AbstractEventListener, rhs: AbstractEventListener) -> Bool {
        return lhs === rhs || lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    func handleEvents(_ events: [DXFeedFramework.MarketEvent]) {
        fatalError("Please, override this method")
    }
}

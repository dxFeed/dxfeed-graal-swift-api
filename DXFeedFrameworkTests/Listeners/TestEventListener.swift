//
//  TestEventListener.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation
@testable import DXFeedFramework

class AnonymousClass: DXEventListener, Hashable {

    static func == (lhs: AnonymousClass, rhs: AnonymousClass) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine("\(self):\(stringReference(self))")
    }
    var callback: ([MarketEvent]) -> Void = { _ in }

    func receiveEvents(_ events: [MarketEvent]) {
        self.callback(events)
    }

    init(overrides: (AnonymousClass) -> AnonymousClass) {
        _ = overrides(self)
    }
}

//
//  TestEventListener.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation
@testable import DxFeedSwiftFramework

class AnonymousClass: DXEventListener, Hashable {
    let name: String = String("\(Int(Date().timeIntervalSince1970 * 1000))")

    static func == (lhs: AnonymousClass, rhs: AnonymousClass) -> Bool {
        lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    var printFunc: ([MarketEvent]) -> Void = { _ in }

    func receiveEvents(_ events: [MarketEvent]) {
        self.printFunc(events)
    }

    init(overrides: (AnonymousClass) -> AnonymousClass) {
        _ = overrides(self)
    }

}

class TestEventListener: DXEventListener, Hashable {
    static func == (lhs: TestEventListener, rhs: TestEventListener) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    let name: String

    init(name: String) {
        self.name = name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    func receiveEvents(_ events: [MarketEvent]) {
//        print(events)
    }
}

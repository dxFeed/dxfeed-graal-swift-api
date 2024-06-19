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
    var someFunc: () -> Void = { }

    func receiveEvents(_ events: [AnyObject]) {
        someFunc()
    }

    init(overrides: (AnonymousClass) -> AnonymousClass) {
        _ = overrides(self)
    }

}

class Test {
    func test() {
        let workingClass = AnonymousClass { res in
            res.someFunc = { print("It worked") }
            return res
        }
        workingClass.receiveEvents([])
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

    func receiveEvents(_ events: [AnyObject]) {

    }
}

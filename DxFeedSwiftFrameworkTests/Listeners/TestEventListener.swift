//
//  TestEventListener.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation
@testable import DxFeedSwiftFramework

class EmptyClass: DXEventListener, Hashable {
    let name: String = String("\(Int(Date().timeIntervalSince1970 * 1000))")

    static func == (lhs: EmptyClass, rhs: EmptyClass) -> Bool {
        lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    var someFunc: () -> () = { }

    func receiveEvents(_ events: [AnyObject]) {
        someFunc()
    }

    init(overrides: (EmptyClass) -> EmptyClass) {
        overrides(self)
    }

}

class Test {
    func test() {
        let workingClass = EmptyClass { ec in
            ec.someFunc = { print("It worked") }
            return ec
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

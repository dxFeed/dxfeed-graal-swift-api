//
//  TestEventListener.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation
@testable import DxFeedSwiftFramework

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

//
//  TestEndpoointStateListener.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 16.10.23.
//

import Foundation
@testable import DXFeedFramework

class TestEndpoointStateListener: DXEndpointObserver, Hashable {
    func endpointDidChangeState(old: DXFeedFramework.DXEndpointState, new: DXFeedFramework.DXEndpointState) {
        callback(new)
    }

    deinit {
        print("deinit TestEndpoointStateListener \(Thread.current.threadName) \(Thread.current.name ?? "")")
    }

    static func == (lhs: TestEndpoointStateListener, rhs: TestEndpoointStateListener) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine("\(self):\(stringReference(self))")
    }
    var callback: (DXEndpointState) -> Void = { _ in }

    init(overrides: (TestEndpoointStateListener) -> TestEndpoointStateListener) {
        _ = overrides(self)
    }
}

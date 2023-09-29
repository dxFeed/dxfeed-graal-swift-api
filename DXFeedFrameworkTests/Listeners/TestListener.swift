//
//  TestListener.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 25.05.23.
//

import Foundation
import XCTest
@testable import DXFeedFramework

class TestListener: DXEndpointObserver, Hashable {
    static func == (lhs: TestListener, rhs: TestListener) -> Bool {
        return lhs.expectations == rhs.expectations
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(expectations)
    }

    var state = DXEndpointState.notConnected
    var expectations: [DXEndpointState: XCTestExpectation]
    init(expectations: [DXEndpointState: XCTestExpectation]) {
        self.expectations = expectations

    }
    func endpointDidChangeState(old: DXEndpointState,
                                new: DXEndpointState) {
        if let expectation = expectations[new] {
            expectation.fulfill()
        }
    }
}

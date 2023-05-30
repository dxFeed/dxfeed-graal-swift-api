//
//  TestListener.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 25.05.23.
//

import Foundation
import XCTest
@testable import DxFeedSwiftFramework

struct TestListener: DXEndpointObserver, Hashable {
    var state = DXEndpointState.notConnected
    var expectations: [DXEndpointState: XCTestExpectation]
    init(expectations: [DXEndpointState: XCTestExpectation]) {
        self.expectations = expectations
    }
    func endpointDidChangeState(old: DxFeedSwiftFramework.DXEndpointState,
                                new: DxFeedSwiftFramework.DXEndpointState) {
        if let expectation = expectations[new] {
            expectation.fulfill()
        }
    }
}

//
//  TestListener.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 25.05.23.
//

import Foundation
import XCTest
@testable import DxFeedSwiftFramework

struct TestListener: DXFEndpointObserver, Hashable {
    var state = DXFEndpointState.notConnected
    var expectations: [DXFEndpointState: XCTestExpectation]
    init(expectations: [DXFEndpointState: XCTestExpectation]) {
        self.expectations = expectations
    }
    func endpointDidChangeState(old: DxFeedSwiftFramework.DXFEndpointState, new: DxFeedSwiftFramework.DXFEndpointState) {
        if let expectation = expectations[new] {
            expectation.fulfill()
        }
    }
}

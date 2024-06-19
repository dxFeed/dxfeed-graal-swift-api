//
//  TestListener.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 25.05.23.
//

import Foundation
import XCTest
@testable import DxFeedSwiftFramework

class TestListener: EndpointListener {
    var state = EndpointState.notConnected
    var expectations: [EndpointState: XCTestExpectation]
    init(expectations: [EndpointState: XCTestExpectation]) {
        self.expectations = expectations
    }
    func changeState(old: DxFeedSwiftFramework.EndpointState, new: DxFeedSwiftFramework.EndpointState) {
        if let expectation = expectations[new] {
            expectation.fulfill()
        }
    }
}

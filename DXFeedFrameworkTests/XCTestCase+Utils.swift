//
//  XCTestCase+Utils.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 25.05.23.
//

import XCTest

extension XCTestCase {
    func wait(seconds: Int) {
        _ = XCTWaiter.wait(for: [expectation(description: "\(seconds) seconds waiting")],
                           timeout: TimeInterval(seconds))
    }
}

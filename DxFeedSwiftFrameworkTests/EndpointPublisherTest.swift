//
//  EndpointPublisherTest.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 25.05.23.
//

import XCTest
@testable import DxFeedSwiftFramework

final class EndpointPublisherTest: XCTestCase {
    func testCreation() throws {
        var endpoint: DXEndpoint? = try DXEndpoint.builder().withRole(.publisher).build()
        let expectations = [DXEndpointState.connected: expectation(description: "Connected"),
                            DXEndpointState.connecting: expectation(description: "Connecting")]
        let listener = TestListener(expectations: expectations)
        endpoint?.add(listener)
        try endpoint?.connect(":4700")
        let exps = Array(expectations.filter({ element in
            element.key != .notConnected
        }).values)
        wait(for: exps, timeout: 1)
        endpoint = nil
        wait(seconds: 2)
    }
}

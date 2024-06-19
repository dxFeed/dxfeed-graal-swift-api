//
//  EventsTest.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 30.05.23.
//

import XCTest
@testable import DxFeedSwiftFramework

final class EventsTest: XCTestCase {
    func testConversion() throws {
        let difValues = EventCode.differentCodesAfterConversation()
        XCTAssert(difValues.count == 0, "Not equal enums. Please, take a look on \(difValues)")
    }
}

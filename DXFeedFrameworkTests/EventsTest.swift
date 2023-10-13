//
//  EventsTest.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 30.05.23.
//

import XCTest
@testable import DXFeedFramework

final class EventsTest: XCTestCase {
    func testConversion() throws {
        let convertedSet = Set(EventCode.allCases.map { $0.nativeCode() }.compactMap { EventCode.convert($0)  })
        let difValues = Array(Set(EventCode.allCases).symmetricDifference(convertedSet))
        XCTAssert(difValues.count == 0, "Not equal enums. Please, take a look on \(difValues)")
    }
}

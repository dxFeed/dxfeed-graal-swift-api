//
//  DateTests.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 06.10.23.
//

import XCTest
@testable import DXFeedFramework

final class DateTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDateConvert() throws {
        XCTAssert(19700101 == DayUtil.getYearMonthDayByDayId(0))
        XCTAssert(19700103 == DayUtil.getYearMonthDayByDayId(Int32(2)))
        XCTAssert(19700104 == DayUtil.getYearMonthDayByDayId(Int64(3)))
        XCTAssert(19700105 == DayUtil.getYearMonthDayByDayId(Int64(4)))
        XCTAssert(19700106 == DayUtil.getYearMonthDayByDayId(Int(5)))
    }

}

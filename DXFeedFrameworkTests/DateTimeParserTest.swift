//
//  DateTimeParserTest.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 28.09.23.
//

import XCTest
@testable import DXFeedFramework

final class DateTimeParserTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testZero() {
        XCTAssert(TimeUtil.parse(" 0    ") == Date(millisecondsSince1970: 0))
    }

    private func checkDate(_ date: Date?, components: DateComponents) {
        guard let date = date else {
            XCTAssert(false, "Date should not be null")
            return
        }
        let calendar = Calendar.current

        let dateComponents = calendar.dateComponents(in: components.timeZone ?? TimeZone.current, from: date)
        print(components)
        print(dateComponents)
        XCTAssert(components.year == dateComponents.year)
        XCTAssert(components.month == dateComponents.month)
        XCTAssert(components.day == dateComponents.day)
        XCTAssert(components.hour == dateComponents.hour)
        XCTAssert(components.minute == dateComponents.minute)
        XCTAssert(components.second == dateComponents.second)
    }

    func testDate1() {
        checkDate(TimeUtil.parse("20070101-123456"),
                  components: DateComponents(year: 2007, month: 01, day: 01, hour: 12, minute: 34, second: 56))
        checkDate(TimeUtil.parse("20070101-123456.123"),
                  components: DateComponents(year: 2007, month: 01, day: 01, hour: 12, minute: 34, second: 56))
        checkDate(TimeUtil.parse("2005-12-31 21:00:00"),
                  components: DateComponents(year: 2005, month: 12, day: 31, hour: 21, minute: 0, second: 0))

        checkDate(TimeUtil.parse("2005-12-31 21:00:00.123+03:00"),
                  components: DateComponents(timeZone:
                                                TimeZone(secondsFromGMT: 3 * 60 * 60),
                                             year: 2005,
                                             month: 12,
                                             day: 31,
                                             hour: 21,
                                             minute: 0,
                                             second: 0))
        checkDate(TimeUtil.parse("2005-12-31 23:10:00.123+0400"),
                  components: DateComponents(timeZone:
                                                TimeZone(secondsFromGMT: 4 * 60 * 60),
                                             year: 2005,
                                             month: 12,
                                             day: 31,
                                             hour: 23,
                                             minute: 10,
                                             second: 0))
        checkDate(TimeUtil.parse("2007-11-02Z"),
                  components: DateComponents(timeZone: TimeZone(identifier: "UTC"),
                                             year: 2007,
                                             month: 11,
                                             day: 02,
                                             hour: 0,
                                             minute: 0,
                                             second: 0))

    }

    func testDate2() {
        checkDate(TimeUtil.parse("1"),
                  components: DateComponents(timeZone: TimeZone(identifier: "UTC"),
                                             year: 1970,
                                             month: 1,
                                             day: 1,
                                             hour: 0,
                                             minute: 0,
                                             second: 0))
        checkDate(TimeUtil.parse("2005-11-30 21:00:00Z"),
                  components: DateComponents(timeZone:
                                                TimeZone(identifier: "UTC"),
                                             year: 2005,
                                             month: 11,
                                             day: 30,
                                             hour: 21,
                                             minute: 0,
                                             second: 0))
        checkDate(TimeUtil.parse("2005-11-30T21:00:00Z"),
                  components: DateComponents(timeZone:
                                                TimeZone(identifier: "UTC"),
                                             year: 2005,
                                             month: 11,
                                             day: 30,
                                             hour: 21,
                                             minute: 0,
                                             second: 0))
        checkDate(TimeUtil.parse("2005-11-30T21:00:00"),
                  components: DateComponents(year: 2005,
                                             month: 11,
                                             day: 30,
                                             hour: 21,
                                             minute: 0,
                                             second: 0))
    }
    
}

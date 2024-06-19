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
        let date: Date? = try? DXTimeFormat.defaultTimeFormat?.parse(" 0    ")
        XCTAssert(date == Date(millisecondsSince1970: 0))
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
        XCTAssert(components.year == dateComponents.year, "\(date) Not equals \(components)")
        XCTAssert(components.month == dateComponents.month, "\(date) Not equals \(components)")
        XCTAssert(components.day == dateComponents.day, "\(date) Not equals \(components)")
        XCTAssert(components.hour == dateComponents.hour, "\(date) Not equals \(components)")
        XCTAssert(components.minute == dateComponents.minute, "\(date) Not equals \(components)")
        XCTAssert(components.second == dateComponents.second, "\(date) Not equals \(components)")
    }

    func testDate1() {
        checkDate(try? DXTimeFormat.defaultTimeFormat?.parse("20070101-123456"),
                  components: DateComponents(year: 2007, month: 01, day: 01, hour: 12, minute: 34, second: 56))
        checkDate(try? DXTimeFormat.defaultTimeFormat?.parse("20070101-123456.123"),
                  components: DateComponents(year: 2007, month: 01, day: 01, hour: 12, minute: 34, second: 56))
        checkDate(try? DXTimeFormat.defaultTimeFormat?.parse("2005-12-31 21:00:00"),
                  components: DateComponents(year: 2005, month: 12, day: 31, hour: 21, minute: 0, second: 0))

        checkDate(try? DXTimeFormat.defaultTimeFormat?.parse("2005-12-31 21:00:00.123+03:00"),
                  components: DateComponents(timeZone:
                                                TimeZone(secondsFromGMT: 3 * 60 * 60),
                                             year: 2005,
                                             month: 12,
                                             day: 31,
                                             hour: 21,
                                             minute: 0,
                                             second: 0))
        checkDate(try? DXTimeFormat.defaultTimeFormat?.parse("2005-12-31 23:10:00.123+0400"),
                  components: DateComponents(timeZone:
                                                TimeZone(secondsFromGMT: 4 * 60 * 60),
                                             year: 2005,
                                             month: 12,
                                             day: 31,
                                             hour: 23,
                                             minute: 10,
                                             second: 0))
        checkDate(try? DXTimeFormat.defaultTimeFormat?.parse("2007-11-02Z"),
                  components: DateComponents(timeZone: TimeZone(identifier: "UTC"),
                                             year: 2007,
                                             month: 11,
                                             day: 02,
                                             hour: 0,
                                             minute: 0,
                                             second: 0))

    }

    func testDate2() {
        checkDate(try? DXTimeFormat.defaultTimeFormat?.parse("2005-11-30 21:00:00Z"),
                  components: DateComponents(timeZone:
                                                TimeZone(identifier: "UTC"),
                                             year: 2005,
                                             month: 11,
                                             day: 30,
                                             hour: 21,
                                             minute: 0,
                                             second: 0))
        checkDate(try? DXTimeFormat.defaultTimeFormat?.parse("2005-11-30T21:00:00Z"),
                  components: DateComponents(timeZone:
                                                TimeZone(identifier: "UTC"),
                                             year: 2005,
                                             month: 11,
                                             day: 30,
                                             hour: 21,
                                             minute: 0,
                                             second: 0))
        checkDate(try? DXTimeFormat.defaultTimeFormat?.parse("2005-11-30T21:00:00"),
                  components: DateComponents(year: 2005,
                                             month: 11,
                                             day: 30,
                                             hour: 21,
                                             minute: 0,
                                             second: 0))
    }

    func testWrongDate() {
        let date: Date? = try? DXTimeFormat.defaultTimeFormat?.parse("1")
        XCTAssert(date == nil)
    }

}

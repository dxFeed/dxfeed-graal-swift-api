//
//  ScheduleTest.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 13.09.23.
//

import XCTest
@testable import DXFeedFramework

final class ScheduleTest: XCTestCase {

    override func setUpWithError() throws {

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCorrectScheduleInit() throws {
        do {
            _ = try DXSchedule(scheduleDefinition: "NewYorkETH()")
        } catch {
            XCTAssert(false, "Error \(error)")
        }
    }

    func testGetScheduleDay() throws {
        do {
            let schedule = try DXSchedule(scheduleDefinition: "NewYorkETH()")
            let name = try schedule.getName()
            XCTAssert(name == "US ETH")
            let timeZone = try schedule.getTimeZone()
            XCTAssert(timeZone == "Eastern Standard Time")
        } catch {
            XCTAssert(false, "Error \(error)")
        }
    }

    func testGetCorrectScheduleDay() throws {
        do {
            let schedule = try DXSchedule(scheduleDefinition: "(tz=GMT;de=2300;0=)")
            let timeZone = try schedule.getTimeZone()
            XCTAssert(timeZone == "Greenwich Mean Time")
            let day = try schedule.getDayById(day: 42)
            XCTAssert(day.dayId == 42)
            XCTAssert(day.sessions.count == 1)
        } catch {
            XCTAssert(false, "Error \(error)")
        }
    }

    func testFetchDays() throws {
        // the iOS dxCharts uses same parameters.
        let start = Long(1682072564670)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let end = Long(formatter.date(from: "2023/09/13 14:00")!.timeIntervalSince1970 * 1000)

        let schedule = try DXSchedule(scheduleDefinition: "NewYorkETH()")
        let startDay = try schedule.getDayByTime(time: start)
        let endDay = try schedule.getDayByTime(time: end)
        var sessionBreaks = [ScheduleSession]()
        var extendedHours = [ScheduleSession]()

        for index in startDay.dayId...endDay.dayId {
            let day = try schedule.getDayById(day: index)
            for session in day.sessions where [.noTrading].contains(session.type) {
                sessionBreaks.append(session)
            }
            for session in day.sessions where [.afterMarket, .preMarket, .regular].contains(session.type) {
                extendedHours.append(session)
            }
        }
        XCTAssert(sessionBreaks.count == 246)
        XCTAssert(extendedHours.count == 300)
        XCTAssert(try schedule.getName() == "US ETH")
        XCTAssert(try schedule.getTimeZone() == "Eastern Standard Time")
        XCTAssert(try schedule.getTimeZoneId() == "America/New_York")
    }

    func testWrongScheduleInit() throws {
        do {
            _ = try DXSchedule(scheduleDefinition: "qwerty1234567")
            XCTAssert(false)
        } catch {
            print("Error \(error)")
        }
    }

}
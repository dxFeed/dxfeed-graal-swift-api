//
//  DXScheduleTest.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 13.09.23.
//

import XCTest
@testable import DXFeedFramework

final class DXScheduleTest: XCTestCase {

    override func setUpWithError() throws {

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testCorrectScheduleInit() throws {
//        do {
//            _ = try DXSchedule(scheduleDefinition: "NewYorkETH()")
//        } catch {
//            XCTAssert(false, "Error \(error)")
//        }
//    }
//
//    func testGetScheduleDay() throws {
//        do {
//            let schedule = try DXSchedule(scheduleDefinition: "NewYorkETH()")
//            let name = try schedule.getName()
//            XCTAssert(name == "US ETH")
//            let timeZone = try schedule.getTimeZone()
//            XCTAssert(timeZone == "Eastern Standard Time")
//        } catch {
//            XCTAssert(false, "Error \(error)")
//        }
//    }

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
        let start = Long(1682072564670)
        let end = Long(Date.now.timeIntervalSince1970 * 1000)
        let schedule = try DXSchedule(scheduleDefinition: "NewYorkETH()")


        let startDay = try schedule.getDayByTime(time: start)
        let endDay = try schedule.getDayByTime(time: end)

        for index in startDay.dayId...endDay.dayId {
            let day = try schedule.getDayById(day: index)

            let date = String(format: "%d-%02d-%02d", arguments: [day.year, day.monthOfYear, day.dayOfMonth])
            var sessions = "\n"
            day.sessions.forEach { sch in
                sessions += "\(sch.startTime) \(sch.endTime) \(sch.type) \n"
            }
            print("\(date) \(day.holiday) \(day.shortDay) \(sessions)")

        }

        XCTAssert(try schedule.getName() == "US ETH")
        XCTAssert(try schedule.getTimeZone() == "America/New_York")
    }

//    func testWrongScheduleInit() throws {
//        do {
//            _ = try DXSchedule(scheduleDefinition: "qwerty1234567")
//            XCTAssert(false, "Schould be ")
//        } catch {
//            print("Error \(error)")
//        }
//    }

    

}

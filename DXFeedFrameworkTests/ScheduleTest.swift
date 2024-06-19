//
//  ScheduleTest.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 13.09.23.
//

import XCTest
@testable import DXFeedFramework
@_implementationOnly import graal_api

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

    func testGetScheduleDayByTime() throws {
        do {
            let schedule = try DXSchedule(scheduleDefinition: "(tz=GMT;de=2300;0=)")
            let timeZone = try schedule.getTimeZone()
            XCTAssert(timeZone == "Greenwich Mean Time")
            let day = try schedule.getDayByTime(time: 0)
            XCTAssert(day.dayId == 0)        
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

    func testConvertDayFilter() {
        let allValues = DayFilter.allCases
        let qdValues = allValues.map { dFilter in
            dFilter.toQDValue()
        }
        let equals = qdValues.map { rawValue in
            DayFilter(value: rawValue)
        } == allValues
        XCTAssert(equals)
    }

    func testGetNextDay() throws {
        let startDayId: Int32 = 42
        let schedule = try DXSchedule(scheduleDefinition: "(tz=GMT;de=2300;0=)")
        let timeZone = try schedule.getTimeZone()
        XCTAssert(timeZone == "Greenwich Mean Time")
        let day = try schedule.getDayById(day: startDayId)
        XCTAssert(day.dayId == startDayId)
        XCTAssert(try day.getNext(filter: .any)?.dayId == startDayId + 1)
        XCTAssert(try day.getNext(filter: .any)?.getNext(filter: .any)?.dayId == startDayId + 2)
    }

    func testGetPrevDay() throws {
        let startDayId: Int32 = 42
        let schedule = try DXSchedule(scheduleDefinition: "(tz=GMT;de=2300;0=)")
        let timeZone = try schedule.getTimeZone()
        XCTAssert(timeZone == "Greenwich Mean Time")
        let day = try schedule.getDayById(day: startDayId)
        XCTAssert(day.dayId == startDayId)
        XCTAssert(try day.getPrevious(filter: .any)?.dayId == startDayId - 1)
        XCTAssert(try day.getPrevious(filter: .any)?.getPrevious(filter: .any)?.dayId == startDayId - 2)
    }

    func testConvertSessionFilter() {
        let allValues = SessionFilter.allCases
        let qdValues = allValues.map { dFilter in
            dFilter.toQDValue()
        }
        let equals = qdValues.map { rawValue in
            SessionFilter(value: rawValue)
        } == allValues
        XCTAssert(equals)
    }

    func testFetchNextPrevSession() throws {
        // the iOS dxCharts uses same parameters.
        let start = Long(1682072564670)

        let schedule = try DXSchedule(scheduleDefinition: "NewYorkETH()")
        let startDay = try schedule.getDayByTime(time: start)
        XCTAssert(startDay.sessions.count >= 3)
        let firstSession = startDay.sessions.first

        let nextSession =  try firstSession?.getNext(filter: .any)
        XCTAssert(nextSession == startDay.sessions[1])
        let lastSession =  startDay.sessions.last
        let prevSession =  try lastSession?.getPrevious(filter: .any)
        XCTAssert(prevSession == startDay.sessions[startDay.sessions.count - 2])
    }

    func testDeinitSchedule() throws {
        let start = Long(1682072564670)
        var schedule: DXSchedule? = try DXSchedule(scheduleDefinition: "NewYorkETH()")
        var startDay: ScheduleDay? = try schedule?.getDayByTime(time: start)
        schedule = nil
        var nextDay: ScheduleDay? = try startDay?.getNext(filter: .any)
        var prevDay: ScheduleDay? = try startDay?.getNext(filter: .any)
        startDay = nil
        nextDay = nil
        prevDay = nil
        // waiting here for an explosion in deinit
        let sec = 2
        _ = XCTWaiter.wait(for: [expectation(description: "\(sec) seconds waiting")], timeout: TimeInterval(sec))
    }

    func testDeinitScheduleWithNextPrev() throws {
        let start = Long(1682072564670)
        var schedule: DXSchedule? = try DXSchedule(scheduleDefinition: "NewYorkETH()")
        var startDay: ScheduleDay? = try schedule?.getDayByTime(time: start)
        schedule = nil

        XCTAssert(startDay?.sessions.count ?? 0 >= 3)
        do {
            let firstSession = startDay?.sessions.first

            let nextSession =  try firstSession?.getNext(filter: .any)
            XCTAssert(nextSession == startDay?.sessions[1])
            let lastSession =  startDay?.sessions.last
            let prevSession =  try lastSession?.getPrevious(filter: .any)
        }
        // waiting here for an explosion in deinit
        let sec = 2
        _ = XCTWaiter.wait(for: [expectation(description: "\(sec) seconds waiting")], timeout: TimeInterval(sec))
    }
}

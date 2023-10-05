//
//  IPFTest.swift
//  DXFeedFrameworkTests
//
//  Created by Aleksey Kosylo on 28.08.23.
//

import XCTest
@testable import DXFeedFramework
@_implementationOnly import graal_api

final class IPFTests: XCTestCase {
    class AnonymousProfileListener: DXInstrumentProfileUpdateListener, Hashable {
        static func == (lhs: AnonymousProfileListener, rhs: AnonymousProfileListener) -> Bool {
            lhs === rhs
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine("\(self):\(stringReference(self))")
        }
        var callback: ([InstrumentProfile]) -> Void = { _ in }

        func instrumentProfilesUpdated(_ instruments: [InstrumentProfile]) {
            self.callback(instruments)
        }

        init(overrides: (AnonymousProfileListener) -> AnonymousProfileListener) {
            _ = overrides(self)
        }
    }

    class AnonymousConnectionListener: DXInstrumentProfileConnectionObserver, Hashable {
        static func == (lhs: AnonymousConnectionListener, rhs: AnonymousConnectionListener) -> Bool {
            lhs === rhs
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine("\(self):\(stringReference(self))")
        }
        var callback: (DXFeedFramework.DXInstrumentProfileConnectionState,
                       DXFeedFramework.DXInstrumentProfileConnectionState) -> Void = { _, _  in }

        func connectionDidChangeState(old: DXFeedFramework.DXInstrumentProfileConnectionState,
                                      new: DXFeedFramework.DXInstrumentProfileConnectionState) {
            self.callback(old, new)
        }
        init(overrides: (AnonymousConnectionListener) -> AnonymousConnectionListener) {
            _ = overrides(self)
        }
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDoubleConvert() {
        let sourceLong = Long(1000)
        let result = Double.longBitsToDouble(sourceLong)
        XCTAssert(result == 4.9406564584124654E-321, "Wrong double value")
        let result1 = Double.doubleToRawLongBits(5.11)
        XCTAssert(result1 == 4617439366951353713, "Wrong long value")
        let res2 = Double.doubleToRawLongBits(result)
        XCTAssert(res2  == sourceLong, "Wrong Back convert")
    }

    func testDoubleToString() {
        let double = Double(123123123.3345)
        let result = InstrumentProfileField.formatNumberImpl(double)
        XCTAssert(result == "123123123.3345", "Wrong string convert")
    }

    func testDictEquals() {
        let dict = ["as": 1, "bc": 2]
        let dict2 = ["as": 2, "bc": 1]
        XCTAssert(dict != dict2, "Shouldn't equal")
        var dict3 = ["as": 1]
        dict3["bc"] =  2
        XCTAssert(dict == dict3, "Should equal")
    }

    // swiftlint:disable line_length

    func testReadBytesWithAddress() throws {
        let ipfContent = """
#ETF::=TYPE,SYMBOL,DESCRIPTION,COUNTRY,OPOL,EXCHANGES,CURRENCY,PRICE_INCREMENTS,TRADING_HOURS,SUBTYPES
#INDEX::=TYPE,SYMBOL,DESCRIPTION,COUNTRY,OPOL,CURRENCY,TRADING_HOURS,AUTOCOMPLETE_WEIGHT,MSI_DESCRIPTION
#OPTION::=TYPE,SYMBOL,DESCRIPTION,COUNTRY,OPOL,EXCHANGE_DATA,EXCHANGES,CURRENCY,CFI,MULTIPLIER,PRODUCT,UNDERLYING,SPC,MMY,EXPIRATION,LAST_TRADE,STRIKE,OPTION_TYPE,EXPIRATION_STYLE,SETTLEMENT_STYLE,PRICE_INCREMENTS,TRADING_HOURS,AUTOCOMPLETE_WEIGHT
#PRODUCT::=TYPE,SYMBOL,DESCRIPTION,COUNTRY,OPOL,EXCHANGES,CURRENCY,CFI,PRICE_INCREMENTS,TRADING_HOURS,AUTOCOMPLETE_WEIGHT
#STOCK::=TYPE,SYMBOL,DESCRIPTION,COUNTRY,OPOL,EXCHANGES,CURRENCY,ISIN,PRICE_INCREMENTS,TRADING_HOURS,BITIP_GROSS_SETTLEMENT,BITIP_LAST_UPDATE,BITIP_MARKET,BITIP_MARKET_SEGMENT,BITIP_SYMBOL
OPTION,.SPXW231006C4595,,US,XCBO,,XCBO1,USD,OCEICS,100,,SPX,100,20231006,2023-10-06,2023-10-06,4595,SDO,Weeklys,Close,0.05 3; 0.1,OPRA15(sds=ec0300;hds=jntd3;de=2000;rt=-2000;0=p-20150915r09301615a16301700),
STOCK,EREGL:TR,EREĞLİ DEMİR VE ÇELİK FABRİKALARI1 T.A.Ş.,TR,XIST,XIST,TRY,TRAEREGL91G3,0.01 20; 0.02 50; 0.05 100; 0.1,BIST(name=BIST;tz=Asia/Istanbul;hd=TR;sd=TR;td=12345;de=+0000;0=10001800),N,2021-08-31,MSPOT,Z,EREGL.E
##COMPLETE
"""
        guard let data = ipfContent.data(using: .utf8) else {
            XCTAssert(false, "Wrong data")
            return
        }
        let reader = DXInstrumentProfileReader()
        let instruments = try reader.read(data: data, address: "demo.com")
        XCTAssert(instruments?.count == 2, "Wrong parsing data from file")
    }

    func testReadCompressedBytes() throws {
        let ipfContent = """
#ETF::=TYPE,SYMBOL,DESCRIPTION,COUNTRY,OPOL,EXCHANGES,CURRENCY,PRICE_INCREMENTS,TRADING_HOURS,SUBTYPES
#INDEX::=TYPE,SYMBOL,DESCRIPTION,COUNTRY,OPOL,CURRENCY,TRADING_HOURS,AUTOCOMPLETE_WEIGHT,MSI_DESCRIPTION
#OPTION::=TYPE,SYMBOL,DESCRIPTION,COUNTRY,OPOL,EXCHANGE_DATA,EXCHANGES,CURRENCY,CFI,MULTIPLIER,PRODUCT,UNDERLYING,SPC,MMY,EXPIRATION,LAST_TRADE,STRIKE,OPTION_TYPE,EXPIRATION_STYLE,SETTLEMENT_STYLE,PRICE_INCREMENTS,TRADING_HOURS,AUTOCOMPLETE_WEIGHT
#PRODUCT::=TYPE,SYMBOL,DESCRIPTION,COUNTRY,OPOL,EXCHANGES,CURRENCY,CFI,PRICE_INCREMENTS,TRADING_HOURS,AUTOCOMPLETE_WEIGHT
#STOCK::=TYPE,SYMBOL,DESCRIPTION,COUNTRY,OPOL,EXCHANGES,CURRENCY,ISIN,PRICE_INCREMENTS,TRADING_HOURS,BITIP_GROSS_SETTLEMENT,BITIP_LAST_UPDATE,BITIP_MARKET,BITIP_MARKET_SEGMENT,BITIP_SYMBOL
OPTION,.SPXW231006C4595,,US,XCBO,,XCBO1,USD,OCEICS,100,,SPX,100,20231006,2023-10-06,2023-10-06,4595,SDO,Weeklys,Close,0.05 3; 0.1,OPRA15(sds=ec0300;hds=jntd3;de=2000;rt=-2000;0=p-20150915r09301615a16301700),
STOCK,EREGL:TR,EREĞLİ DEMİR VE ÇELİK FABRİKALARI1 T.A.Ş.,TR,XIST,XIST,TRY,TRAEREGL91G3,0.01 20; 0.02 50; 0.05 100; 0.1,BIST(name=BIST;tz=Asia/Istanbul;hd=TR;sd=TR;td=12345;de=+0000;0=10001800),N,2021-08-31,MSPOT,Z,EREGL.E
##COMPLETE
"""
        guard let data = ipfContent.data(using: .utf8) else {
            XCTAssert(false, "Wrong data")
            return
        }
        let reader = DXInstrumentProfileReader()
        let instruments = try reader.readCompressed(data: data)
        XCTAssert(instruments?.count == 2, "Wrong parsing data from file")
    }

    func testReadBytes() throws {
        let ipfContent = """
#ETF::=TYPE,SYMBOL,DESCRIPTION,COUNTRY,OPOL,EXCHANGES,CURRENCY,PRICE_INCREMENTS,TRADING_HOURS,SUBTYPES
#INDEX::=TYPE,SYMBOL,DESCRIPTION,COUNTRY,OPOL,CURRENCY,TRADING_HOURS,AUTOCOMPLETE_WEIGHT,MSI_DESCRIPTION
#OPTION::=TYPE,SYMBOL,DESCRIPTION,COUNTRY,OPOL,EXCHANGE_DATA,EXCHANGES,CURRENCY,CFI,MULTIPLIER,PRODUCT,UNDERLYING,SPC,MMY,EXPIRATION,LAST_TRADE,STRIKE,OPTION_TYPE,EXPIRATION_STYLE,SETTLEMENT_STYLE,PRICE_INCREMENTS,TRADING_HOURS,AUTOCOMPLETE_WEIGHT
#PRODUCT::=TYPE,SYMBOL,DESCRIPTION,COUNTRY,OPOL,EXCHANGES,CURRENCY,CFI,PRICE_INCREMENTS,TRADING_HOURS,AUTOCOMPLETE_WEIGHT
#STOCK::=TYPE,SYMBOL,DESCRIPTION,COUNTRY,OPOL,EXCHANGES,CURRENCY,ISIN,PRICE_INCREMENTS,TRADING_HOURS,BITIP_GROSS_SETTLEMENT,BITIP_LAST_UPDATE,BITIP_MARKET,BITIP_MARKET_SEGMENT,BITIP_SYMBOL
OPTION,.SPXW231006C4595,,US,XCBO,,XCBO1,USD,OCEICS,100,,SPX,100,20231006,2023-10-06,2023-10-06,4595,SDO,Weeklys,Close,0.05 3; 0.1,OPRA15(sds=ec0300;hds=jntd3;de=2000;rt=-2000;0=p-20150915r09301615a16301700),
STOCK,EREGL:TR,EREĞLİ DEMİR VE ÇELİK FABRİKALARI1 T.A.Ş.,TR,XIST,XIST,TRY,TRAEREGL91G3,0.01 20; 0.02 50; 0.05 100; 0.1,BIST(name=BIST;tz=Asia/Istanbul;hd=TR;sd=TR;td=12345;de=+0000;0=10001800),N,2021-08-31,MSPOT,Z,EREGL.E
##COMPLETE
"""
        guard let data = ipfContent.data(using: .utf8) else {
            XCTAssert(false, "Wrong data")
            return
        }
        let reader = DXInstrumentProfileReader()
        let instruments = try reader.read(data: data)
        XCTAssert(instruments?.count == 2, "Wrong parsing data from file")
    }
    // swiftlint:enable line_length

    func testCollector() throws {
        do {
            let collector = try DXInstrumentProfileCollector()
            let newProfile = InstrumentProfile()
            try collector.updateInstrumentProfile(profile: newProfile)
            let iterator = try collector.view()
            let expectation = expectation(description: "Received profile")
            while (try? iterator.hasNext()) ?? false {
                let profile = try iterator.next()
                XCTAssert(newProfile == profile, "Should be equal")
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1.0)
        } catch {
            print(error)
        }
    }

    func testCollectorWithExecutor() throws {
        let collector = try DXInstrumentProfileCollector()
        let newProfile = InstrumentProfile()
        try collector.updateInstrumentProfile(profile: newProfile)
        let iterator = try collector.view()
        let expectation = expectation(description: "Received profile")
        while (try? iterator.hasNext()) ?? false {
            let profile = try iterator.next()
            XCTAssert(newProfile == profile, "Should be equal")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testProfileListener() throws {
        let collector = try DXInstrumentProfileCollector()
        let expectation = expectation(description: "Received profile")
        let newProfile = InstrumentProfile()
        newProfile.symbol = "TEST_123"
        let listener = AnonymousProfileListener { anonymCl in
            anonymCl.callback = { profiles in
                if profiles.count == 1 {
                    let profile = profiles.first
                    if profile == newProfile {
                        expectation.fulfill()
                    }
                }
            }
            return anonymCl
        }
        try collector.add(observer: listener)

        try collector.updateInstrumentProfile(profile: newProfile)
        wait(for: [expectation], timeout: 1.0)

    }

    func testConnectionState() {
        func checkFunction(_ graalState: dxfg_ipf_connection_state_t, apiState: DXInstrumentProfileConnectionState) {
            XCTAssert(DXInstrumentProfileConnectionState.convert(graalState) == apiState, "\(apiState) state: wrong")
        }
        checkFunction(DXFG_IPF_CONNECTION_STATE_CLOSED, apiState: .closed)
        checkFunction(DXFG_IPF_CONNECTION_STATE_COMPLETED, apiState: .completed)
        checkFunction(DXFG_IPF_CONNECTION_STATE_CONNECTED, apiState: .connected)
        checkFunction(DXFG_IPF_CONNECTION_STATE_CONNECTING, apiState: .connecting)
        checkFunction(DXFG_IPF_CONNECTION_STATE_NOT_CONNECTED, apiState: .notConnected)
    }

    func testConnection() throws {
        guard let address = ProcessInfo.processInfo.environment["ipf_address"] else {
            throw XCTSkip("Please input address")
        }
        let expectationCollector = expectation(description: "Collector")
        expectationCollector.assertForOverFulfill = false
        let collector = try DXInstrumentProfileCollector()
        let observer0 = AnonymousProfileListener { anonymCl in
            anonymCl.callback = { profiles in
                if profiles.count > 0 {
                    expectationCollector.fulfill()
                }
            }
            return anonymCl
        }
        try collector.add(observer: observer0)
        let expectationConnection = expectation(description: "Connection")
        expectationConnection.expectedFulfillmentCount = 3 // connecting, connected, completed
        let connection = try DXInstrumentProfileConnection(address, collector)
        let observer = AnonymousConnectionListener { anonymCl in
            anonymCl.callback = { _, new in
                switch new {
                case .notConnected:
                    break
                case .connecting:
                    expectationConnection.fulfill()
                case .connected:
                    expectationConnection.fulfill()
                case .completed:
                    expectationConnection.fulfill()
                case .closed:
                    break
                }
            }
            return anonymCl
        }
        connection.add(observer: observer)
        try connection.start()
        wait(for: [expectationConnection, expectationCollector], timeout: 20.0)

    }

    func testCreateOnScheduledThreadPool() throws {
        let collector = try DXInstrumentProfileCollector()
        let result = try collector.createOnScheduledThreadPool(numberOfThreads: 15, nameOfthread: "test_ios_thread")
        XCTAssert(result, "createOnScheduledThreadPool failed")
    }

    func testCreateOnConcurrentLinkedQueue() throws {
        let collector = try DXInstrumentProfileCollector()
        let result = try collector.createOnConcurrentLinkedQueue()
        XCTAssert(result, "createOnConcurrentLinkedQueue failed")
    }

    func testCreateOnFixedThreadPool() throws {
        let collector = try DXInstrumentProfileCollector()
        let result = try collector.createOnFixedThreadPool(numberOfThreads: 15, nameOfthread: "test_ios_thread")
        XCTAssert(result, "createOnFixedThreadPool failed")
    }
}

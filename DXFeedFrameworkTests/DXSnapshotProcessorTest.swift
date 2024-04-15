//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

final class DXSnapshotProcessorTest: XCTestCase, SnapshotDelegate {
    lazy var receivedEventExp = {
        expectation(description: "Received snapshot")
    }()

    func receiveEvents(_ events: [DXFeedFramework.MarketEvent], isSnapshot: Bool) {
        if isSnapshot {
            receivedEventExp.fulfill()
        }
        print("Update data \(events.count) \(isSnapshot)")
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
        defer {
            try? endpoint.closeAndAwaitTermination()
        }
        let feed = endpoint.getFeed()
        let subscription = try feed?.createSubscription([Candle.self])
        let snapshotProcessor = SnapshotProcessor()
        snapshotProcessor.add(self)
        try subscription?.add(listener: snapshotProcessor)
        let symbol = TimeSeriesSubscriptionSymbol(symbol: "AAPL{=1d}", date: Date.init(millisecondsSince1970: 0))
        try subscription?.addSymbols(symbol)
        wait(for: [receivedEventExp], timeout: 4.0)
    }
}

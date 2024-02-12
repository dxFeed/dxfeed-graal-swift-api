//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

final class DXPromiseTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetResult() throws {
        let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
        let feed = endpoint.getFeed()
        let promise = try feed?.getLastEventPromise(type: Trade.self, symbol: "ETH/USD:GDAX")
        XCTAssert(promise?.hasResult() == false)
        let result = try promise?.await(millis: 1000)
        XCTAssert(result === promise?.getResult())
        print(promise?.hasResult() == true)
    }

    func testGetResults() throws {
        let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
        let feed = endpoint.getFeed()
        let promises = try feed?.getLastEventPromises(type: Quote.self, symbols: ["ETH/USD:GDAX", "AAPL"])
        try promises?.forEach({ promise in
            let result = try promise.await(millis: 1000)
            print(result?.quote.askPrice)
            print(result?.quote.bidPrice)
        })
    }
}

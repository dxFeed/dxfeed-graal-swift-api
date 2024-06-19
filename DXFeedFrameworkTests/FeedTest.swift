//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import XCTest
@testable import DXFeedFramework

final class FeedTest: XCTestCase {

    override class func setUp() {
        _ = Isolate.shared
    }

    func testInitializationWithNilNativeSubscription() {
        XCTAssertThrowsError(try DXFeedSubscription(native: nil, types: [Quote.self])) { error in
            // Assert
            XCTAssertTrue(error is ArgumentException)
        }
    }

    func testCreateSymbol() throws {
        // "as Any" to avoid compile time warnings
        XCTAssertNotNil(("AAPL" as Any) as? Symbol, "String is not a symbol")
        print("asd".description)
        XCTAssertNotNil((WildcardSymbol.all as Any) as? Symbol, "String is not a symbol")
        print(WildcardSymbol.all.stringValue)
        let symbol = try CandleSymbol.valueOf("test")
        XCTAssertNotNil((TimeSeriesSubscriptionSymbol(symbol: symbol,
                                                      fromTime: 0) as Any) as? Symbol, "String is not a symbol")

        let symbol1 = try CandleSymbol.valueOf("test")
        let testString = TimeSeriesSubscriptionSymbol(symbol: symbol1, fromTime: 10).stringValue
    }

    func testSetGetSymbols() throws {
        let symbols: [Symbol] = [
            "AAPL_TEST",
            "AAPL_TEST{=d}",
            WildcardSymbol.all,
            CandleSymbol.valueOf("AAPL0", [CandlePeriod.day]),
            TimeSeriesSubscriptionSymbol(symbol: "AAPL2", fromTime: 1),
            IndexedEventSubscriptionSymbol(symbol: "AAPL1", source: .defaultSource),
            IndexedEventSubscriptionSymbol(symbol: "AAPL3", source: OrderSource.ntv!),
            IndexedEventSubscriptionSymbol(symbol: "AAPL4", source: try OrderSource.valueOf(identifier: 1))
        ]
        let endpoint = try DXEndpoint.create()
        let feed = try endpoint.getFeed()?.createSubscription([Candle.self])
        try feed?.setSymbols(symbols)
        if let resultSymbols = try feed?.getSymbols() {
            // Using sets for comparing.
            let inputSymbols = symbols.reduce(into: Set<String>(), { (values, object) in
                values.insert(object.stringValue)
            })
            XCTAssert(inputSymbols.count == symbols.count)
            let equals = inputSymbols == resultSymbols.reduce(into: Set<String>(), { (values, object) in
                values.insert(object.stringValue)
            })
            XCTAssert(equals)
        } else {
            XCTAssert(false, "Subscription returned null")
        }
    }
}

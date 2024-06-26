//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

final class DXOptionChainTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let ipfFile = "https://demo:demo@tools.dxfeed.com/ipf"
        let symbol = "AAPL"
        let nStrikes = 10
        var nMoths = 12

        let endpoint = try DXEndpoint.create().connect("demo.dxfeed.com:7300")
        guard let feed = endpoint.getFeed() else {
            print("Feed is nil")
            exit(-1)
        }

        print("Waiting for price of \(symbol) ...")
        let promise = try feed.getLastEventPromise(type: Trade.self, symbol: symbol).await(millis: 2000)
        if promise.hasResult()  == false {
            print("Promise hasn't  result")
            exit(-1)
        }

        guard let trade = try promise.getResult()?.trade else {
            print("Trade is nil")
            exit(-1)
        }
        print("Reading instruments from \(ipfFile) ...")
        let price = trade.price
        print("Price of \(symbol) is \(price)")

        guard let instruments = try DXInstrumentProfileReader().readFromFile(address: ipfFile) else {
            exit(-1)
        }
        print("Building option chains ...")
        let chains = OptionChainsBuilder<InstrumentProfile>.build(instruments)
        guard let chain = chains.getChains()[symbol] else {
            print("Chain is nil")
            exit(-1)
        }

        nMoths = min(nMoths, chain.getSeries().count)
        let seriesList = chain.getSeries()[0..<nMoths]

        print("Requesting option quotes ...")

        var quotes = [InstrumentProfile: Promise]()
        try seriesList.forEach { series in
            let strikes = try series.getNStrikesAround(numberOfStrikes: nStrikes, strike: price)
            try strikes.forEach { strike in
                if let call = series.calls[strike] {
                    quotes[call] = try feed.getLastEventPromise(type: Quote.self, symbol: call.symbol)
                }
                if let put = series.putts[strike] {
                    quotes[put] = try feed.getLastEventPromise(type: Quote.self, symbol: put.symbol)
                }

            }
        }
        // ignore timeout and continue to print retrieved quotes even on timeout
        _ = try Promise.allOf(promises: Array(quotes.values))?.awaitWithoutException(millis: 1000)

        print("Printing option series ...")
        try seriesList.forEach { series in
            print("Option series \(series.toString())")
            let strikes = try series.getNStrikesAround(numberOfStrikes: nStrikes, strike: price)
            print("C.BID".paddingSpaces(), "C.ASK".paddingSpaces(), "STRIKE".paddingSpaces(), "P.BID".paddingSpaces(), "P.ASK".paddingSpaces())
            try strikes.forEach { strike in
                var resultString = ""
                func fetchQuoteString(_ quote: Quote) -> String {
                    return "\(quote.bidPrice.paddingSpaces()) \(quote.askPrice.paddingSpaces())"
                }
                if let call = series.calls[strike] {
                    let quote = try quotes[call]?.getResult() ?? Quote(symbol)
                    resultString += fetchQuoteString(quote.quote)
                } else {
                    resultString += fetchQuoteString(Quote(symbol))
                }
                resultString += " \(strike.paddingSpaces()) "
                if let put = series.putts[strike] {
                    let quote = try quotes[put]?.getResult() ?? Quote(symbol)
                    resultString += fetchQuoteString(quote.quote)
                } else {
                    resultString += fetchQuoteString(Quote(symbol))
                }
                print(resultString)
            }
        }
    }
}

fileprivate extension String {
    func paddingSpaces(_ toLength: Int = 10) -> String {
        return self.padding(toLength: toLength, withPad: " ", startingAt: 0)
    }
}

fileprivate extension Double {
    func paddingSpaces(_ toLength: Int = 10) -> String {
        return "\(self)".padding(toLength: toLength, withPad: " ", startingAt: 0)
    }
}

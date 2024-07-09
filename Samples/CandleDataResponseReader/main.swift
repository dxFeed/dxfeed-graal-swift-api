//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import DXFeedFramework

// swiftlint:disable line_length
/// Demonstrates how to parse response from CandleData service.
/// Candlewebservice provides Candle and TimeAndSale data for particular time period
/// in the past with from-to period via REST-like API.
/// For more details see [KB](https://kb.dxfeed.com/en/data-services/aggregated-data-services/candlewebservice.html).
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyyMMdd"

var start = Calendar.current.date(byAdding: .day,
                                  value: -2,
                                  to: Date())!
let stop = Calendar.current.date(byAdding: .day,
                                 value: -1,
                                 to: Date())!
// URL for fetching candle events.
let candleUrl = "https://tools-demo.dxfeed.com/candledata-preview?records=Candle&symbols=IBM{=h}&start=\(dateFormatter.string(from: start))&stop=\(dateFormatter.string(from: stop))&format=csv&compression=gzip"
let downloaderCandle = Downloader(user: "demo",
                                  password: "demo",
                                  urlString: candleUrl)
downloaderCandle.download { str in
    if let string = str {
        // Parse the response content into a list of Candle events.
        let candleList = try? CandleParser().parse(string)
        print("Received candles count: \(candleList?.count ?? 0)")
    } else {
        print("Please, check url and credentials")
    }
}

let tnsDateFormatter = DateFormatter()
tnsDateFormatter.dateFormat = "yyyyMMdd-hhmmss"
var startTns = Calendar.current.date(byAdding: .hour,
                                  value: -26,
                                  to: Date())!
let stopTns = Calendar.current.date(byAdding: .hour,
                                 value: -24,
                                 to: Date())!
// URL for fetching tns events.
let tnsUrl = "https://tools-demo.dxfeed.com/candledata-preview?records=TimeAndSale&symbols=IBM&start=\(tnsDateFormatter.string(from: startTns))&stop=\(tnsDateFormatter.string(from: stopTns))&format=csv&compression=gzip"

let tnsDownloader = Downloader(user: "demo",
                               password: "demo",
                               urlString: tnsUrl)
tnsDownloader.download { str in
    if let string = str {
        // Parse the response content into a list of TimeAndSale events.
        let tnsList = try? TimeAndSaleParser().parse(string)
        print("Received tns count: \(tnsList?.count ?? 0)")
    } else {
        print("Please, check url and credentials")
    }
}
_ = readLine()
// swiftlint:enable line_length

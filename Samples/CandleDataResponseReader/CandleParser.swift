//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
import DXFeedFramework
import SwiftCSV

class CandleParser: EventParser {
    func parse(_ csv: String) throws -> [DXFeedFramework.MarketEvent] {
        var candles = [Candle]()
        let tsv: CSV = try CSV<Enumerated>(string: csv)
        let header = tsv.header
        try tsv.rows.forEach { values in
            var event: Candle?

            for index in 0..<values.count {
                let value = values[index]

                if index == header.count {
                    event?.eventFlags = CandleParser.parseEventflags(value)
                } else {
                    let headerKey = header[index]
                    switch headerKey {
                    case "#=Candle": break
                    case "EventSymbol":
                        event = Candle(try CandleSymbol.valueOf(value))
                    case "EventTime":
                        let time: Long? = try DXTimeFormat.defaultTimeFormat?.parse(value)
                        event?.eventTime = time ?? 0
                    case "Time":
                        let time: Long? = try DXTimeFormat.defaultTimeFormat?.parse(value)
                        event?.time = time ?? 0
                    case "Sequence":
                        if value.isEmpty || value == "0" {
                            break
                        }
                        let millisAndSequence = value.split(separator: ":")
                        if millisAndSequence.count == 2 {
                            let sequence = millisAndSequence[1]
                            try? event?.setSequence(Int(sequence) ?? 0)
                        }
                        event?.time = (event?.time ?? 0) + (Int64(String(millisAndSequence.first!)) ?? 0)
                    case "Count":
                        event?.count = Long(value) ?? 0
                    case "Open":
                        event?.open = Double(value) ?? .nan
                    case "High":
                        event?.high = Double(value) ?? .nan
                    case "Low":
                        event?.low = Double(value) ?? .nan
                    case "Close":
                        event?.close = Double(value) ?? .nan
                    case "Volume":
                        event?.volume = Double(value) ?? .nan
                    case "VWAP":
                        event?.vwap = Double(value) ?? .nan
                    case "BidVolume":
                        event?.bidVolume = Double(value) ?? .nan
                    case "AskVolume":
                        event?.askVolume = Double(value) ?? .nan
                    case "ImpVolatility":
                        event?.impVolatility = Double(value) ?? .nan
                    case "OpenInterest":
                        event?.openInterest = Double(value) ?? .nan
                    default:
                        print("Undefined key \(headerKey)")
                    }
                }
            }
            if let candle = event {
                candles.append(candle)
            }
        }
        return candles
    }

}

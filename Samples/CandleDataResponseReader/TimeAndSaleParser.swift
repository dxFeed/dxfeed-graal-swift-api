//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
import DXFeedFramework
import SwiftCSV

class TimeAndSaleParser: EventParser {
    func parse(_ csv: String) throws -> [DXFeedFramework.MarketEvent] {
        var events = [TimeAndSale]()
        let tsv: CSV = try CSV<Enumerated>(string: csv)
        let header = tsv.header
        try tsv.rows.forEach { values in
            var event: TimeAndSale?
            for index in 0..<values.count {
                let value = values[index]

                if index == header.count {
                    event?.eventFlags = TimeAndSaleParser.parseEventflags(value)
                } else {
                    let headerKey = header[index]
                    switch headerKey {
                    case "#=TimeAndSale": break
                    case "EventSymbol":
                        event = TimeAndSale(value)
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
                    case "ExchangeCode":
                        event?.exchangeCode = StringUtil.decodeChar(value)
                    case "Price":
                        event?.price = Double(value) ?? .nan
                    case "Size":
                        event?.size = Double(value) ?? .nan
                    case "BidPrice":
                        event?.bidPrice = Double(value) ?? .nan
                    case "AskPrice":
                        event?.askPrice = Double(value) ?? .nan
                    case "SaleConditions":
                        event?.exchangeSaleConditions = value
                    case "Flags":
                        event?.flags = Int32(value) ?? 0
                    case "Buyer":
                        // add parsing null as string
                        event?.buyer = value == "\\NULL" ? nil : value
                    case "Seller":
                        event?.seller = value == "\\NULL" ? nil : value
                    default:
                        print("Undefined key \(headerKey)")
                    }
                }
            }
            if let event = event {
                events.append(event)
            }
        }
        return events
    }

}

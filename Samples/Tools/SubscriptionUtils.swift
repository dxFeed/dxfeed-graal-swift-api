//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import DXFeedFramework

class Subscription {
    var endpoint: DXEndpoint?
    var subscriptions = [DXFeedSubcription]()

    // swiftlint:disable function_parameter_count
    func createSubscription<O>(address: String,
                               symbols: [Symbol],
                               types: [EventCode],
                               role: DXEndpoint.Role,
                               listeners: [O],
                               properties: [String: String],
                               time: String?,
                               source: String? = nil)
    where O: DXEventListener, O: Hashable {
        print("""
Create subscription to \(address) for \(types): \
\(symbols.count > 20 ? Array(symbols[0..<20]) : symbols) with properties:\(properties) and time \(time ?? "---")
""")
        endpoint = try? DXEndpoint
            .builder()
            .withRole(role)
            .withProperties(properties)
            .withName("SubscriptionEndpoint")
            .build()
        _ = try? endpoint?.connect(address)
        types.forEach { str in
            let subscription = try? endpoint?.getFeed()?.createSubscription(str)

            listeners.forEach { listener in
                try? subscription?.add(listener: listener)
            }
            if time != nil {
                guard let date: Date = try? DXTimeFormat.defaultTimeFormat?.parse(time!) else {
                    fatalError("Couldn't parse string \(time ?? "") to Date object")
                }
                let timeSubscriptionSymbols = symbols.map { symbol in
                    TimeSeriesSubscriptionSymbol(symbol: symbol, date: date)
                }
                print(symbols)
                print(date)
                print(timeSubscriptionSymbols)
                try? subscription?.addSymbols(timeSubscriptionSymbols)
            } else if source != nil {
                if let source = try? OrderSource.valueOf(name: source!) {
                        let indexedEventSubscriptionSymbols = symbols.map { symbol in
                            IndexedEventSubscriptionSymbol(symbol: symbol, source: source)
                    }
                    try? subscription?.addSymbols(indexedEventSubscriptionSymbols)
                }
            } else {
                try? subscription?.addSymbols(symbols)
            }
            if let subscription = subscription {
                subscriptions.append(subscription)
            }
        }
    }
    // swiftlint:enable function_parameter_count

}

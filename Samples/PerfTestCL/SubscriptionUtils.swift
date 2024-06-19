//
//  SubscriptionUtils.swift
//  Tools
//
//  Created by Aleksey Kosylo on 28.09.23.
//

import Foundation
import DXFeedFramework

class Subscription {
    var endpoint: DXEndpoint?
    var subscriptions = [DXFeedSubcription]()

    func createSubscription<O>(address: String,
                               symbols: [String],
                               types: String,
                               listener: O,
                               time: String?)
    where O: DXEventListener,
          O: Hashable {
              endpoint = try? DXEndpoint.builder().withRole(.feed).build()
              _ = try? endpoint?.connect(address)
              types.split(separator: ",").forEach { str in
                  let subscription = try? endpoint?.getFeed()?.createSubscription(EventCode(string: String(str)))
                  try? subscription?.add(observer: listener)
                  if time != nil {
                      guard let date = TimeUtil.parse(time!) else {
                          fatalError("Couldn't parse string \(time ?? "") to Date object")
                      }
                      let timeSubscriptionSymbols = symbols.map { symbol in
                          TimeSeriesSubscriptionSymbol(symbol: symbol, date: date)
                      }
                      try? subscription?.addSymbols(timeSubscriptionSymbols)
                  } else {
                      try? subscription?.addSymbols(symbols)
                  }
                  if let subscription = subscription {
                      subscriptions.append(subscription)
                  }
              }
          }
}

//
//  DataSource.swift
//  VisionQuoteTableApp
//
//  Created by Aleksey Kosylo on 29.06.23.
//

import Foundation
import DxFeedSwiftFramework

class DataSource: ObservableObject {
    @Published var quotes: [QuoteViewModel] = []
    var quotesDict: [String: QuoteViewModel]
    init(symbols: [String]) {
        quotes = [QuoteViewModel]()
        quotesDict = [String: QuoteViewModel]()
        symbols.forEach {
            let model = QuoteViewModel(symbol: $0)
            quotes.append(model)
            quotesDict[$0] = model
        }
    }

    func update(_ value: Quote) {
        DispatchQueue.main.async {
            let model = self.quotesDict[value.eventSymbol]
            model?.updatePrice(ask: value.askPrice, bid: value.bidPrice)
        }
    }

    func update(_ value: Profile) {
        DispatchQueue.main.async {
            let model = self.quotesDict[value.eventSymbol]
            model?.updateDescription(value.descriptionStr)
        }
    }
}

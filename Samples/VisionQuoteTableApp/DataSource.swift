//
//  DataSource.swift
//  VisionQuoteTableApp
//
//  Created by Aleksey Kosylo on 29.06.23.
//

import Foundation
import DXFeedFramework

class DataSource: ObservableObject {
    @Published var quotes: [QuoteViewModel] = []
    private let quotesDict: [String: QuoteViewModel]

    init(symbols: [String]) {
        var quotesList = [QuoteViewModel]()
        var quotesDict = [String: QuoteViewModel]()
        symbols.forEach {
            let model = QuoteViewModel(symbol: $0)
            quotesList.append(model)
            quotesDict[$0] = model
        }
        self.quotes = quotesList
        self.quotesDict = quotesDict
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

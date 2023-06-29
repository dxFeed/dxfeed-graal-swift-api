//
//  DataSource.swift
//  VisionQuoteTableApp
//
//  Created by Aleksey Kosylo on 29.06.23.
//

import Foundation
import DxFeedSwiftFramework

class DataSource: ObservableObject {
    @Published var quotes: [QuoteViewModel]
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
        let model = quotesDict[value.eventSymbol]

    }

    func update(_ value: Profile) {
        let model = quotesDict[value.eventSymbol]
        model?.updateDescription(value.descriptionStr)
        print(quotesDict)
        print(quotes)
    }
}

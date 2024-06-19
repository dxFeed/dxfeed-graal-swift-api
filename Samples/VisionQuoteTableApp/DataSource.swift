//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
            model?.updateDescription(value.descriptionStr ?? "")
        }
    }
}

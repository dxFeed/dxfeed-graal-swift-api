//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

class QuoteViewModel: Identifiable, Hashable, ObservableObject {
    var id: String = ""
    @Published var title = ""
    @Published var askPrice = ""
    @Published var askColor = UIColor.priceBackground
    @Published var bidPrice = ""
    @Published var bidColor = UIColor.priceBackground

    private var symbol = ""
    private var previousAskPrice = 0.0
    private var previousBidPrice = 0.0

    static private var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        return formatter
    }()

    func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }

    static func == (lhs: QuoteViewModel, rhs: QuoteViewModel) -> Bool {
        lhs.symbol == rhs.symbol
    }

    init(symbol: String) {
        self.id = symbol
        self.symbol = symbol
        updateDescription("")
    }

    func updateDescription(_ desc: String) {
        self.title = "\(self.symbol)\n\(desc)"
    }

    func updatePrice(ask: Double, bid: Double) {
        self.askPrice = QuoteViewModel.numberFormatter.string(from: NSNumber(value: ask) ) ?? ""
        self.askColor = newPriceColor(current: ask, previous: previousAskPrice)
        self.previousAskPrice = ask
        self.bidPrice = QuoteViewModel.numberFormatter.string(from: NSNumber(value: bid) ) ?? ""
        self.bidColor = newPriceColor(current: bid, previous: previousBidPrice)
        self.previousBidPrice = bid
    }

    private func newPriceColor(current: Double, previous: Double) -> UIColor {
        if previous == 0 {
            return .priceBackground
        }
        if current > previous {
            return .greenBackground
        } else {
            return .redBackground
        }
    }
}

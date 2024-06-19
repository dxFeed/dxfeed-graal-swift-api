//
//  QuoteViewModel.swift
//  VisionQuoteTableApp
//
//  Created by Aleksey Kosylo on 29.06.23.
//

import Foundation
import UIKit

class QuoteViewModel: Identifiable, Hashable  {
    var id: String = ""
    @Published var title = ""
    @Published var askPrice = ""
    @Published var askColor = UIColor.priceBackground
    @Published var bidPrice = ""
    @Published var bidColor = UIColor.priceBackground

    private var symbol = ""

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
        DispatchQueue.main.async {
            self.title = "\(self.symbol)\n\(desc)"
        }
    }
}

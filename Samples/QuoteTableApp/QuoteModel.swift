//
//  QuoteModel.swift
//  TestApp
//
//  Created by Aleksey Kosylo on 07.06.23.
//

import Foundation
import DxFeedSwiftFramework

class QuoteModel {

    let formatter = NumberFormatter()

    private var current: Quote?
    private var previous: Quote?
    private var descriptionStr: String = ""

    init() {
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
    }

    var ask: String {
        guard let price = current?.askPrice else {
            return "0"
        }
        let number = NSNumber(value: price)
        return formatter.string(from: number) ?? ""
    }

    var bid: String {
        guard let price = current?.bidPrice else {
            return "0"
        }
        let number = NSNumber(value: price)
        return formatter.string(from: number) ?? ""
    }

    var descriptionString: String {
        return descriptionStr
    }

    var increaseAsk: Bool? {
        guard let current = current?.askPrice, let previous = previous?.askPrice else {
            return nil
        }
        return current > previous
    }

    var increaseBid: Bool? {
        guard let current = current?.bidPrice, let previous = previous?.bidPrice else {
            return nil
        }
        return current > previous
    }

    func update(_ value: Quote) {
        previous = current
        current = value
    }

    func update(_ desc: String) {
        descriptionStr = desc
    }

}

//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import DXFeedFramework

class QuoteModel {

    let formatter = NumberFormatter()

    private var current: Quote?
    private var previous: Quote?
    private var descriptionStr: String = ""

    init() {
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
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

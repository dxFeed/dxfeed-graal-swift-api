//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

struct InstrumentInfo: Codable {
    let symbol: String
    let descriptionStr: String
}

extension InstrumentInfo: Comparable {
    static func < (lhs: InstrumentInfo, rhs: InstrumentInfo) -> Bool {
        return lhs.symbol < rhs.symbol
    }
}

class SymbolsDataProvider {
    static let kSelectedSymbolsKey = "kSelectedSymbolsKey"
    static let kSymbolsKey = "kSymbolsKey"

    init() {
    }

    var allSymbols: [InstrumentInfo] {
        get {
            if let data = UserDefaults.standard.value(forKey: SymbolsDataProvider.kSymbolsKey) as? Data {
                let myObject = try? PropertyListDecoder().decode([InstrumentInfo].self, from: data)
                return myObject ?? [InstrumentInfo]()
            }
            return [InstrumentInfo]()
        }
        set {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue),
                                      forKey: SymbolsDataProvider.kSymbolsKey)
            UserDefaults.standard.synchronize()
        }
    }

    var selectedSymbols: [String] {
        let existingSymbols = UserDefaults.standard.object(forKey: SymbolsDataProvider.kSelectedSymbolsKey)
        if existingSymbols != nil {
            return existingSymbols as? [String] ?? [String]()
        } else {
            return ["AAPL", "IBM", "MSFT", "CSCO", "GOOG", "PFE"]
        }
    }

    func addSymbols(_ symbols: Set<String>) {
        var currentSymbols = selectedSymbols
        let newValues = symbols.subtracting(Set(currentSymbols))

        currentSymbols.removeAll(where: { value in
            let notExist = !symbols.contains(value)
            return notExist
        })
        UserDefaults.standard.set(currentSymbols + newValues.sorted(), forKey: SymbolsDataProvider.kSelectedSymbolsKey)
        UserDefaults.standard.synchronize()
    }

    func changeSymbols(_ symbols: [String]) {
        UserDefaults.standard.set(symbols, forKey: SymbolsDataProvider.kSelectedSymbolsKey)
        UserDefaults.standard.synchronize()
    }
}

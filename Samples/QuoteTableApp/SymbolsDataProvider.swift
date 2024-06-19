//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

class SymbolsDataProvider {
    static let kSelectedSymbolsKey = "kSelectedSymbolsKey"
    static let kSymbolsKey = "kSymbolsKey"

    init() {
    }

    var allSymbols: [String] {
        get {
            return (UserDefaults.standard.object(forKey: SymbolsDataProvider.kSymbolsKey) as? [String]) ?? [String]()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SymbolsDataProvider.kSymbolsKey)
            UserDefaults.standard.synchronize()
        }
    }

    var selectedSymbols: [String] {
        get {
            return (UserDefaults.standard.object(forKey: SymbolsDataProvider.kSelectedSymbolsKey) as? [String]) ?? [String]()
        }
//        set {
//            let currentSymbols = selectedSymbols
//            let newValues = Set(newValue).subtracting(Set(currentSymbols))
//            UserDefaults.standard.set(currentSymbols + newValues, forKey: SymbolsDataProvider.kSelectedSymbolsKey)
//        }
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

        let currentSymbols1 = selectedSymbols
        print(currentSymbols1)
    }

    func changeSymbols(_ symbols: [String]) {
        UserDefaults.standard.set(symbols, forKey: SymbolsDataProvider.kSelectedSymbolsKey)
        UserDefaults.standard.synchronize()
    }


}

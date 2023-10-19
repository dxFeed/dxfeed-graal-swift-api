//
//  Arguments.swift
//  Tools
//
//  Created by Aleksey Kosylo on 19.10.23.
//

import Foundation
import DXFeedFramework

class Arguments {

    let arguments: [String]
    let symbolPosition: Int

    init(arguments: [String], symbolPosition: Int) {
        self.arguments = arguments
        self.symbolPosition = symbolPosition
    }

    

    func parseSymbols() -> [String] {
        let symbols = arguments[symbolPosition]
        var symbolsList = [String]()
        func addSymbol(str: String) {
            if str.hasPrefix("ipf[") && str.hasSuffix("]") {
                if let address = str.slice(from: "[", to: "]") {
                    let profiles = try? DXInstrumentProfileReader().readFromFile(address: address)
                    profiles?.forEach({ profile in
                        symbolsList.append(profile.symbol)
                    })
                }
            } else {
                symbolsList.append(str)
            }
        }
        var parentheses = 0
        var tempSrting = ""
        symbols.forEach { character in
            switch character {
            case "{", "(", "[":
                parentheses += 1
                tempSrting.append(character)
            case "}", ")", "]":
                if parentheses > 0 {
                    parentheses -= 1
                }
                tempSrting.append(character)
            case ",":
                if parentheses == 0 {
                    addSymbol(str: tempSrting)
                    tempSrting = ""
                } else {
                    tempSrting.append(character)
                }
            default:
                tempSrting.append(character)
            }
        }

        addSymbol(str: tempSrting)
        return symbolsList
    }
}

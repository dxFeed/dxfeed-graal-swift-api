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

    lazy var properties: [String: String] = {
        var properties = [String: String]()
        if let propIndex = arguments.firstIndex(of: "-p") {
            arguments[propIndex + 1].split(separator: ",").forEach { substring in
                let prop = substring.split(separator: "=")
                if prop.count == 2 {
                    properties[String(prop.first!)] = String(prop.last!)
                } else {
                    print("Wrong property \(prop)")
                }
            }
        }
        return properties
    }()

    lazy var isQuite: Bool = {
        if let isQuiteIndex = arguments.firstIndex(of: "-q") {
            return true
        }
        return false
    }()

    lazy var tape: String? = {
        if let tapeIndex = arguments.firstIndex(of: "-t") {
            return arguments[tapeIndex + 1]
        }
        return nil
    }()

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

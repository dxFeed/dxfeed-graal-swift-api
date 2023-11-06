//
//  ArgumentParser.swift
//  Tools
//
//  Created by Aleksey Kosylo on 21.09.23.
//

import Foundation
import DXFeedFramework

enum ArgumentParserException: Error {
    case error(message: String)
}

/// Be careful with indexes
/// The command name is included in the resulting array
/// and therefore 0 is not the first parameter. It is command name
class Arguments {
    private let allParameters: [String]
    private let namelessParameters: [String]

    public lazy var properties: [String: String] = {
        var properties = [String: String]()
        if let propIndex = allParameters.firstIndex(of: "-p") {
            allParameters[propIndex + 1].split(separator: ",").forEach { substring in
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

    public lazy var isQuite: Bool = {
        if let isQuiteIndex = allParameters.firstIndex(of: "-q") {
            return true
        }
        return false
    }()

    public lazy var tape: String? = {
        if let tapeIndex = allParameters.firstIndex(of: "-t") {
            return allParameters[tapeIndex + 1]
        }
        return nil
    }()

    public lazy var time: String? = {
        if let tapeIndex = allParameters.firstIndex(of: "-f") {
            return allParameters[tapeIndex + 1]
        }
        return nil
    }()

    public lazy var source: String? = {
        if let tapeIndex = allParameters.firstIndex(of: "-s") {
            return allParameters[tapeIndex + 1]
        }
        return nil
    }()

    init(_ cmd: [String], requiredNumberOfArguments: Int) throws {
        print("Parse \(cmd) to \(requiredNumberOfArguments) arguments")

        if cmd.count - 1 < requiredNumberOfArguments {
            throw ArgumentParserException.error(message:
"""
Cmd \(cmd) contains not enough \(cmd.count - 1) arguments. Expected \(requiredNumberOfArguments)
""")
        }
        // 0 Arg is path to executed app
        self.allParameters =  Array(cmd[1..<cmd.count])
        if let firstNamedParameter = cmd.firstIndex(where: { str in
            str.hasPrefix("-")
        }) {
            self.namelessParameters = Array(cmd[1..<firstNamedParameter])
        } else {
            self.namelessParameters = self.allParameters
        }
    }

    public subscript(index: Int) -> String {
        namelessParameters[index]
    }

    public var count: Int {
        namelessParameters.count
    }

    public func parseTypes(at index: Int) -> [EventCode] {
        if namelessParameters.count <= index {
            return EventCode.allCases
        }

        if namelessParameters[2] == "all" {
            return EventCode.allCases
        }
        return namelessParameters[2].split(separator: ",").compactMap { str in
            return EventCode(string: String(str))
        }
    }

    public func parseSymbols(at index: Int) -> [Symbol] {
        if namelessParameters.count <= index {
            return [WildcardSymbol.all]
        }

        let symbols = namelessParameters[index]
        if symbols.lowercased() == "all" {
            return [WildcardSymbol.all]
        }

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

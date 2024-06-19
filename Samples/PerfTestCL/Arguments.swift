//
//  ArgumentParser.swift
//  PerfTestCL
//
//  Created by Aleksey Kosylo on 21.09.23.
//

import Foundation
import DXFeedFramework

enum ArgumentParserException: Error {
    case error(message: String)
}

class Arguments {
    private let arguments: [String]

    public lazy var properties: [String: String] = {
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

    public lazy var isQuite: Bool = {
        if let isQuiteIndex = arguments.firstIndex(of: "-q") {
            return true
        }
        return false
    }()

    public lazy var tape: String? = {
        if let tapeIndex = arguments.firstIndex(of: "-t") {
            return arguments[tapeIndex + 1]
        }
        return nil
    }()

    public lazy var time: String? = {
        if arguments.count > 4 {
            return arguments[4]
        } else {
            return nil
        }
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
        self.arguments =  Array(cmd[1..<cmd.count])
    }

    public subscript(index: Int) -> String {
        arguments[index]
    }

    public var count: Int {
        arguments.count
    }

    public func parseTypes(at index: Int) -> [EventCode] {
        if arguments[2] == "all" {
            return EventCode.allCases
        }
        return arguments[2].split(separator: ",").compactMap { str in
            return EventCode(string: String(str))
        }
    }

    public func parseSymbols(at index: Int) -> [Symbol] {
        let symbols = arguments[index]
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

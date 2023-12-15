//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
    struct ArgParameter {
        let shortName: String?
        let longName: String?

        public static func == (lhs: ArgParameter,
                               rhs: String) -> Bool {
            if let shortName = lhs.shortName {
                if "-\(shortName)" == rhs {
                    return true
                }
            }
            if let longName = lhs.longName {
                if "--\(longName)" == rhs {
                    return true
                }
            }
            return false
        }
    }

    private let allParameters: [String]
    private let namelessParameters: [String]

    private let propertiesParameter = ArgParameter(shortName: "p", longName: "properties")
    private let quiteParameter = ArgParameter(shortName: "q", longName: "quite")
    private let forceStreamParameter = ArgParameter(shortName: nil, longName: "force-stream")
    private let tapeParameter = ArgParameter(shortName: "t", longName: "tape")
    private let fromTimeParameter = ArgParameter(shortName: "f", longName: "from-time")
    private let sourceParameter = ArgParameter(shortName: "s", longName: "source")

    public lazy var properties: [String: String] = {
        var properties = [String: String]()
        if let propIndex = allParameters.firstIndex(where: { return propertiesParameter == $0 }) {
            allParameters[propIndex + 1].split(separator: ",").forEach { substring in
                let prop = substring.split(separator: "=")
                if prop.count == 2 {
                    properties[String(prop.first!)]  = String(prop.last!)
                } else {
                    print("Wrong property \(prop)")
                }
            }
        }
        return properties
    }()

    private func value(for param: ArgParameter) -> Bool {
        if allParameters.firstIndex(where: { param == $0 }) != nil {
            return true
        }
        return false
    }

    private func value(for param: ArgParameter) -> String? {
        if let tapeIndex = allParameters.firstIndex(where: { param == $0 }) {
            return allParameters[tapeIndex + 1]
        }
        return nil
    }

    public lazy var isQuite: Bool = {
        return value(for: quiteParameter)
    }()

    public lazy var isForceStream: Bool = {
        return value(for: forceStreamParameter)
    }()

    public lazy var tape: String? = {
        return value(for: tapeParameter)
    }()

    public lazy var time: String? = {
        return value(for: fromTimeParameter)
    }()

    public lazy var source: String? = {
        return value(for: sourceParameter)
    }()

    public lazy var qdsCommandLine: [String]? = {
        var result = [String]()
        for str in namelessParameters[1..<namelessParameters.count] {
            let splited = str.split(separator: " ")
            if splited.count == 1 {
                result.append(str)
            } else {
                splited.forEach { substring in
                    result.append(String(substring))
                }
            }
        }
        return result
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

    public func parseSymbols() -> [Symbol] {
        let symbolsPosition = 3
        if namelessParameters.count <= symbolsPosition {
            return [WildcardSymbol.all]
        }
        let symbols = namelessParameters[symbolsPosition]
        if symbols.lowercased() == "all" {
            return [WildcardSymbol.all]
        }
        return (try? SymbolParser.parse(symbols)) ?? [String]()
    }
}

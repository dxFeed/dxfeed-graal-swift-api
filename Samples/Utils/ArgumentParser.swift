//
//  ArgumentParser.swift
//  PerfTestCL
//
//  Created by Aleksey Kosylo on 21.09.23.
//

import Foundation

enum ArgumentParserException: Error {
    case error(message: String)
}

class ArgumentParser {

    func parse(_ cmd: [String], numberOfPossibleArguments: Int) throws -> [String] {
        print("Parse \(cmd) to \(numberOfPossibleArguments) arguments")

        if cmd.count - 1 < numberOfPossibleArguments {
            throw ArgumentParserException.error(message:
"""
Cmd \(cmd) contains not enough \(cmd.count - 1) arguments. Expected \(numberOfPossibleArguments)
""")
        }
        return Array(cmd[1...numberOfPossibleArguments])
    }
}

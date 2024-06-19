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

    func parse(_ cmd: [String], requiredNumberOfArguments: Int) throws -> [String] {
        print("Parse \(cmd) to \(requiredNumberOfArguments) arguments")

        if cmd.count - 1 < requiredNumberOfArguments {
            throw ArgumentParserException.error(message:
"""
Cmd \(cmd) contains not enough \(cmd.count - 1) arguments. Expected \(requiredNumberOfArguments)
""")
        }

        return Array(cmd[1..<cmd.count])
    }
}

//
//  main.swift
//  SwiftTestCLI
//
//  Created by Aleksey Kosylo on 20.02.2023.
//

import Foundation

let commands: [ToolsCommand] = [PerfTestCommand(),
                                ConnectCommand(),
                                LatencyTestCommand(),
                                LiveIpfCommand(),
                                ScheduleCommand(),
                                IpfConnectCommand(),
                                HelpCommand()]

func getCommand(_ cmd: String) -> ToolsCommand? {
    return commands.first { command in
        command.cmd == cmd
    }
}

func getCommandsDecription() -> String {
    let maxSize = (commands.max { cmd1, cmd2 in
        cmd1.cmd.count < cmd2.cmd.count
    }?.cmd.count ?? 0) + 4
    let descriptions = commands.map { cmd in
        let spaces = maxSize - cmd.cmd.count
        return "  \(cmd.cmd + String(repeating: " ", count: spaces)): \(cmd.shortDescription)"
    }.joined(separator: "\n")

    return descriptions
}

func printGlobalHelp() {
    print(
"""
A collection of useful utilities that use the dxFeed API.

Usage:
  Tools <tool> [...]

Where:

\(getCommandsDecription())

"""
    )
}

var arguments: [String]
do {
    arguments = try ArgumentParser().parse(ProcessInfo.processInfo.arguments, requiredNumberOfArguments: 1)
} catch {
    printGlobalHelp()
    print(error)

    exit(1)
}

let command = arguments[0]

switch command {
case "Help":
    printGlobalHelp()
default:
    if let toolsCmd = getCommand(command) {
        toolsCmd.execute()
    } else {
        printGlobalHelp()
    }
}

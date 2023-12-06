//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

let commands: [ToolsCommand] = [PerfTestTool(),
                                ConnectTool(),
                                LatencyTestTool(),
                                DumpTool(),
                                QdsTool(),
                                HelpTool()]

func getCommand(_ cmd: String) -> ToolsCommand? {
    let cmd = cmd.lowercased()
    return commands.first { command in
        command.cmd.lowercased() == cmd
    }
}

func getCommandsDecription() -> String {
    let maxSize = (commands.max { cmd1, cmd2 in
        cmd1.cmd.count < cmd2.cmd.count
    }?.cmd.count ?? 0) + 4
    let descriptions = commands.compactMap { cmd in
        if cmd.isTools {
            let spaces = maxSize - cmd.cmd.count
            return "  \(cmd.cmd + String(repeating: " ", count: spaces)): \(cmd.shortDescription)"
        } else {
            return nil
        }
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
if ProcessInfo.processInfo.arguments.count > 1 {
    let command = ProcessInfo.processInfo.arguments[1]
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
} else {
    printGlobalHelp()
}

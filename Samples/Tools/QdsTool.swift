//
//  QdsTool.swift
//  Tools
//
//  Created by Aleksey Kosylo on 05.12.23.
//

import Foundation
import DXFeedFramework

class QdsTool: ToolsCommand {
    var isTools: Bool = true
    var cmd = "Qds"
    var shortDescription = "A collection of tools ported from the Java qds-tools."

    var fullDescription  =
"""
Qds
=======

Usage:
  Qds <arg> [<options>]

Where:

  value pos. 0        Required.
  -p, --properties    Comma-separated list of properties (key-value pair separated by an equals sign).
"""

    private lazy var arguments: Arguments = {
        do {
            let arguments = try Arguments(ProcessInfo.processInfo.arguments, requiredNumberOfArguments: 1)
            return arguments
        } catch {
            print(fullDescription)
            exit(0)
        }
    }()

    func execute() {
        do {
            try arguments.properties.forEach { key, value in
                try SystemProperty.setProperty(key, value)
            }
            try QdsUtils.execute(arguments.qdsCommandLine ?? [String]())
        } catch {
            print("Qds tool error: \(error)")
        }

    }
}

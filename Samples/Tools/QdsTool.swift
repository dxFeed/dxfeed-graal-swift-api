//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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

  args (pos. 0)       Required. Represents the arguments passed to the qds-tools.
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

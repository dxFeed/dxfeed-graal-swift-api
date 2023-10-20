//
//  HelpCommand.swift
//  Tools
//
//  Created by Aleksey Kosylo on 27.09.23.
//

import Foundation

class HelpCommand: ToolsCommand {
    var isTools: Bool = true
    var cmd = "Help"

    var shortDescription = "Help tool."

    var fullDescription: String = ""

    func execute() {
    }
}

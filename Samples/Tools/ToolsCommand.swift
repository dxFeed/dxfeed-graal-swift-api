//
//  ToolsCommand.swift
//  Tools
//
//  Created by Aleksey Kosylo on 26.09.23.
//

import Foundation

protocol ToolsCommand {
    var isTools: Bool { get }
    var cmd: String { get }
    var shortDescription: String { get }
    var fullDescription: String { get }
    func execute()
}

//
//  GraalException.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 16.03.2023.
//

import Foundation

enum GraalException: Error {
    case undefined
    case fail(message: String, className: String, stack: String)
    case isolateFail(message: String)
}

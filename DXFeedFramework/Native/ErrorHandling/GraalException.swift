//
//  GraalException.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 16.03.2023.
//

import Foundation

/// Represents errors that occur when calling graal function.
public enum GraalException: Error {
    case undefined
    case fail(message: String, className: String, stack: String)
    case isolateFail(message: String)
}

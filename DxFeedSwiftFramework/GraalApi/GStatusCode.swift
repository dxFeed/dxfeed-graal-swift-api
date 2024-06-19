//
//  GStatusCode.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 16.03.2023.
//

import Foundation

enum GStatusCode: Equatable {
    case success
    case fail(message: String, className: String, stack: String)
}

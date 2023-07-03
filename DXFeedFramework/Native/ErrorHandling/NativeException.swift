//
//  UninitializedNativeException.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 23.05.23.
//

import Foundation

enum NativeException: Error {
    case nilValue
    case argumentException(type: String)
}

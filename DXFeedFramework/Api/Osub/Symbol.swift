//
//  Symbol.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation

/// Protocol for implement your custom symbol
///
/// Dervied from  this procol can be used with ``DXFeedSubcription`` to specify subscription

public protocol Symbol {
    /// Custom symbol has to return string representation.
    var stringValue: String { get }
}

extension Symbol {
    public var stringValue: String {
        fatalError("Symbol.stringValue has not been implemented")
    }
}

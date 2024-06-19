//
//  Symbol.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation

public protocol Symbol {
    var stringValue: String { get }
}

extension Symbol {
    public var stringValue: String {
#warning("TODO: implement it")
        return "empty description for \(type(of: self)). please change"
    }
}

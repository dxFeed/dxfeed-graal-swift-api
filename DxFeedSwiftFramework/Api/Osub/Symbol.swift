//
//  Symbol.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation

protocol Symbol {
    var stringValue: String { get }
}

extension Symbol {
    var stringValue: String {
#warning("TODO: implement it")
        return "empty description for \(type(of: self)). please change"
    }
}

//
//  String+Symbol.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation

extension String: Symbol {
    public var stringValue: String {
        return description
    }
}


//
//  String+Symbol.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 01.06.23.
//

import Foundation

extension String: Symbol {
    var stringValue: String {
        return description
    }
}

//
//  Character+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 22.08.23.
//

import Foundation

extension Character {
    init(_ value: Int) {
        if let myUnicodeScalar = UnicodeScalar(value) {
            self.init(myUnicodeScalar)
        } else {
            self.init("")
        }
    }
}

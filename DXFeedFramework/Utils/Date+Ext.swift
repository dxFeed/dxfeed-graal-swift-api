//
//  Date+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 30.08.23.
//

import Foundation

extension Date {
    var millisecondsSince1970: TimeInterval {
        return timeIntervalSince1970 * 1000
    }

    public init(millisecondsSince1970: Long) {
        self.init(timeIntervalSince1970: Double(millisecondsSince1970) / 1000)
    }
}

//
//  Double+Equals.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 09.08.23.
//

import Foundation

infix operator ~==
infix operator ~<=
infix operator ~>=

extension Double {
    static func ~== (lhs: Double, rhs: Double) -> Bool {
        // If we add even a single zero more,
        // our Decimal test would fail.
        fabs(lhs - rhs) < 0.000000000001
    }

    static func ~<= (lhs: Double, rhs: Double) -> Bool {
        (lhs < rhs) || (lhs ~== rhs)
    }

    static func ~>= (lhs: Double, rhs: Double) -> Bool {
        (lhs > rhs) || (lhs ~== rhs)
    }
}

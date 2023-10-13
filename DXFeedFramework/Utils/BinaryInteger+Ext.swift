//
//  BinaryInteger+Ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 21.08.23.
//

import Foundation

extension BinaryInteger {
    func roundedTowardZero(toMultipleOf multiplier: Self) -> Self {
        return self - (self % multiplier)
    }

    func roundedAwayFromZero(toMultipleOf multiplier: Self) -> Self {
        let xValue = self.roundedTowardZero(toMultipleOf: multiplier)
        if xValue == self { return xValue }
        return (multiplier.signum() == self.signum()) ? (xValue + multiplier) : (xValue - multiplier)
    }

    func roundedDown(toMultipleOf multiplier: Self) -> Self {
        return (self < 0) ? self.roundedAwayFromZero(toMultipleOf: multiplier)
        : self.roundedTowardZero(toMultipleOf: multiplier)
    }

    func roundedUp(toMultipleOf multiplier: Self) -> Self {
        return (self > 0) ? self.roundedAwayFromZero(toMultipleOf: multiplier)
        : self.roundedTowardZero(toMultipleOf: multiplier)
    }

    func toHexString() -> String {
        return "0x\(String(format: "%01X", Int(self)))"
    }
}

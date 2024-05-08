//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
        return "0x\(String(self, radix: 16))"
    }

    func compare(_ rhs: Self) -> ComparisonResult {
        if self < rhs {
            return .orderedAscending
        } else if self > rhs {
            return .orderedDescending
        } else {
            return .orderedSame
        }
    }
}

extension BinaryFloatingPoint {
    func compare(_ rhs: Self) -> ComparisonResult {
        if self < rhs {
            return .orderedAscending
        } else if self > rhs {
            return .orderedDescending
        } else {
            return .orderedSame
        }
    }
}


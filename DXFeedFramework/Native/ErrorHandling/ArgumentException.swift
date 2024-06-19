//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Represents errors that occur when candle manipulations
public enum ArgumentException: Error {
    case missingCandleType
    case missingCandlePrice
    case missingCandleSession
    case unknowCandleType
    case unknowCandlePrice
    case unknowCandleAlignment
    case unknowCandleSession
    case argumentNil
    case invalidOperationException(_ message: String)
    case duplicateValue
    case duplicateId
    case incorrectCandlePrice
    case unknowCandlePriceLevel
    case illegalArgumentException
    case exception(_ message: String)
    case unknowValue(_ value: String, _ supportedValues: String? = nil)
}

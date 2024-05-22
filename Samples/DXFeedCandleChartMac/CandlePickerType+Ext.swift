//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
import DXFeedFramework

extension CandlePickerType {
    func toDxFeedValue() -> CandlePeriod {
        switch self {
        case .week:
            return CandlePeriod.valueOf(value: 1, type: .week)
        case .month:
            return CandlePeriod.valueOf(value: 1, type: .month)
        case .year:
            return CandlePeriod.valueOf(value: 1, type: .year)
        case .minute:
            return CandlePeriod.valueOf(value: 1, type: .minute)
        case .day:
            return CandlePeriod.valueOf(value: 1, type: .day)
        case .hour:
            return CandlePeriod.valueOf(value: 1, type: .hour)
        }
    }

    func calcualteStartDate() -> Date {
        switch self {
        case .minute:
            return Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        case .hour:
            return Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        case .day:
            return Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        case .week:
            return Calendar.current.date(byAdding: .year, value: -5, to: Date())!
        case .month:
            return Calendar.current.date(byAdding: .year, value: -10, to: Date())!
        case .year:
            return Date(timeIntervalSince1970: 0)
        }
    }
}

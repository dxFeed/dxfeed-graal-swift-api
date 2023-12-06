//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

class TimeNanosUtil {
    private static let NanosInMillis = Long(1_000_000)

    static func getNanosFromMillisAndNanoPart(_ timeMillis: Long, _ timeNanoPart: Int32) -> Long {
        return (timeMillis * NanosInMillis) + Long(timeNanoPart)
    }

    static func getMillisFromNanos(_ timeNanos: Long) -> Long {
        return MathUtil.floorDiv(timeNanos, NanosInMillis)
    }

    static func getNanoPartFromNanos(_ timeNanos: Long) -> Long {
        return MathUtil.floorMod(timeNanos, NanosInMillis)
    }

}

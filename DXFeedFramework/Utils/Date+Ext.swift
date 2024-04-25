//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

extension Date {
    func millisecondsSince1970() -> TimeInterval {
        return timeIntervalSince1970 * 1000
    }

    func millisecondsSince1970() -> Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }

    init(millisecondsSince1970: Long) {
        self.init(timeIntervalSince1970: Double(millisecondsSince1970) / 1000)
    }
}

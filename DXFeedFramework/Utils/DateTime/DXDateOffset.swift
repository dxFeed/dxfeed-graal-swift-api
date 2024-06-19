//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

public class DXDateOffset {
    public let era: Int32
    public let year: Int32
    public let month: Int32
    public let day: Int32
    public let dayOfWeek: Int32
    public let milliseconds: Int32

    public init(era: Int32, year: Int32, month: Int32, day: Int32, dayOfWeek: Int32, milliseconds: Int32) {
        self.era = era
        self.year = year
        self.month = month
        self.day = day
        self.dayOfWeek = dayOfWeek
        self.milliseconds = milliseconds
    }
}

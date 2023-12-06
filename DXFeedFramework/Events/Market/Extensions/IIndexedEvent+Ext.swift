//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Used extensions only to overcome swift limitation (cannot use initialized values in protocol)
public extension IIndexedEvent {
    static var txPending: Int32 {
        return 0x01
    }
    static var removeEvent: Int32 {
        return 0x02
    }
    static var snapshotBegin: Int32 {
        return 0x04
    }
    static var snapshotEnd: Int32 {
        return 0x08
    }
    static var snapshotSnip: Int32 {
        return 0x10
    }
    static var snapShotMode: Int32 {
        return 0x40
    }
}

//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import DXFeedFramework

class EventListener: DXEventListener, Hashable {

    let callback: ([MarketEvent]) -> Void

    init(callback: @escaping ([MarketEvent]) -> Void) {
        self.callback = callback
    }

    func receiveEvents(_ events: [DXFeedFramework.MarketEvent]) {
        callback(events)
    }

    static func == (lhs: EventListener, rhs: EventListener) -> Bool {
        return lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(stringReference(self))
    }
}

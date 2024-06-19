//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import DXFeedFramework

class AbstractEventListener: DXEventListener, Hashable {
    lazy var name = {
        stringReference(self)
    }()

    func receiveEvents(_ events: [DXFeedFramework.MarketEvent]) {
        handleEvents(events)
    }

    static func == (lhs: AbstractEventListener, rhs: AbstractEventListener) -> Bool {
        return lhs === rhs || lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    func handleEvents(_ events: [DXFeedFramework.MarketEvent]) {
        fatalError("Please, override this method")
    }
}

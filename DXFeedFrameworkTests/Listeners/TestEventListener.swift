//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@testable import DXFeedFramework

class AnonymousClass: DXEventListener, Hashable {

    static func == (lhs: AnonymousClass, rhs: AnonymousClass) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine("\(self):\(stringReference(self))")
    }
    var callback: ([MarketEvent]) -> Void = { _ in }

    func receiveEvents(_ events: [MarketEvent]) {
        self.callback(events)
    }

    init(overrides: (AnonymousClass) -> AnonymousClass) {
        _ = overrides(self)
    }
}

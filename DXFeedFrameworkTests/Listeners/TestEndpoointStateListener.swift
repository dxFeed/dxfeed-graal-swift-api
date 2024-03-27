//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@testable import DXFeedFramework

class TestEndpoointStateListener: DXEndpointListener, Hashable {
    func endpointDidChangeState(old: DXFeedFramework.DXEndpointState, new: DXFeedFramework.DXEndpointState) {
        callback(new)
    }

    static func == (lhs: TestEndpoointStateListener, rhs: TestEndpoointStateListener) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine("\(self):\(stringReference(self))")
    }
    var callback: (DXEndpointState) -> Void = { _ in }

    init(overrides: (TestEndpoointStateListener) -> TestEndpoointStateListener) {
        _ = overrides(self)
    }
}

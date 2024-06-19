//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

public extension DXInstrumentProfileConnectionState {
    func convetToString() -> String {
        var status = "Not connected 🔴"
        switch self {
        case .notConnected:
            status = "Not connected 🔴"
        case .connecting:
            status = "Connecting 🟠"
        case .connected:
            status = "Connected 🟢"
        case .closed:
            status = "Closed 🔴"
        case .completed:
            status = "Completed 🟢"
        }
        return status
    }
}

//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Instrument profile connection state.
public enum DXInstrumentProfileConnectionState {
    /// Instrument profile connection is not started yet.
    /// ``DXInstrumentProfileConnection/start()`` was not invoked yet.
    case notConnected
    /// Connection is being established.
    case connecting
    /// Connection was established.
    case connected
    /// Initial instrument profiles snapshot was fully read (this state is set only once).
    case completed
    /// Instrument profile connection was ``DXInstrumentProfileConnection/close()``.
    case closed
}

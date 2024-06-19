//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// A list of endpoint states.
public enum DXEndpointState {
    /// Endpoint was created by is not connected to remote endpoints.
    case notConnected
    /// The ``DXEndpoint/connect(_:)`` method was called to establish connection to remove endpoint,
    /// but connection is not actually established yet or was lost.
    case connecting
    /// The connection to remote endpoint is established.
    case connected
    /// Endpoint was ``DXEndpoint/close()``
    case closed
}

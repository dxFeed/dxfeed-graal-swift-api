//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

extension DXEndpointState {
    static func convert(_ state: dxfg_endpoint_state_t) -> DXEndpointState? {
        switch state {
        case DXFG_ENDPOINT_STATE_CLOSED:
            return .closed
        case DXFG_ENDPOINT_STATE_CONNECTED:
            return .connected
        case DXFG_ENDPOINT_STATE_CONNECTING:
            return .connecting
        case DXFG_ENDPOINT_STATE_NOT_CONNECTED:
            return .notConnected
        default:
            return nil
        }
    }
}

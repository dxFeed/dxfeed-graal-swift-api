//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Notifies a change in the state of this endpoint.
public protocol DXEndpointListener: AnyObject {
    /// Fired when state changed
    /// 
    /// - Parameters:
    ///     - old: The old state of endpoint
    ///     - new: The new state of endpoint
    func endpointDidChangeState(old: DXEndpointState, new: DXEndpointState)
}

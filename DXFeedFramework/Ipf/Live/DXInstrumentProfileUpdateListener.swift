//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
/// The listener delegate for receiving instrument profiles.
public protocol DXInstrumentProfileUpdateListener: AnyObject {
    /// Invoked when instrument profiles received
    ///
    /// - Parameters:
    ///   - instruments: The collection of received profiles.
    func instrumentProfilesUpdated(_ instruments: [InstrumentProfile])
}

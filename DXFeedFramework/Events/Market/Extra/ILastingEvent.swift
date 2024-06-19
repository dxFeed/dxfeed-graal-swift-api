//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
/// Represents up-to-date information about some
/// condition or state of an external entity that updates in real-time.
///
/// For example, a ``Quote`` is an up-to-date information about best bid and best offer for a specific symbol.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/LastingEvent.html)
public protocol ILastingEvent: IEventType {
}

//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

extension ScheduleSessionType {
    static func getValueFromNative(_ type: dxfg_session_type_t) -> ScheduleSessionType {
        switch type {
        case DXFG_SESSION_TYPE_NO_TRADING:
            return .noTrading
        case DXFG_SESSION_TYPE_PRE_MARKET:
            return .preMarket
        case DXFG_SESSION_TYPE_REGULAR:
            return .regular
        case DXFG_SESSION_TYPE_AFTER_MARKET:
            return .afterMarket
        default:
            fatalError()
        }
    }
}

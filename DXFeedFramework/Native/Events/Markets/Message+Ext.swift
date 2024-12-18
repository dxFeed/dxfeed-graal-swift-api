//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
@_implementationOnly import graal_api

extension TextMessage {
    convenience init(native: dxfg_text_message_t) {
        self.init(String(pointee: native.event_symbol))

        self.eventTime = native.event_time
        self.timeSequence = native.time_sequence
        if native.text != nil {
            native.text.withMemoryRebound(to: CChar.self, capacity: 1) { pointer in
                self.text = String(nullable: pointer)
            }
        }
    }

}

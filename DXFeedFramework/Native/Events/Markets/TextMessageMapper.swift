//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
@_implementationOnly import graal_api

class TextMessageMapper: Mapper {
    var type = dxfg_text_message_t.self

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) -> MarketEvent? {
        let event = native.withMemoryRebound(to: type, capacity: 1) { native in
            return TextMessage(native: native.pointee)
        }
        return event
    }

    func toNative(event: MarketEvent) -> UnsafeMutablePointer<dxfg_event_type_t>? {
        let pointer = UnsafeMutablePointer<dxfg_text_message_t>.allocate(capacity: 1)

        pointer.pointee.event_symbol = event.eventSymbol.toCStringRef()
        pointer.pointee.event_time = event.eventTime
        pointer.pointee.text = nil

        let message = event.textMessage

        pointer.pointee.time_sequence = message.timeSequence
        if let tempAttachment: UnsafePointer<CChar> = message.text?.toCStringRef() {
            pointer.pointee.text = tempAttachment
        }

        let eventType = pointer.withMemoryRebound(to: dxfg_event_type_t.self, capacity: 1) { pointer in
            pointer.pointee.clazz = DXFG_EVENT_TEXT_MESSAGE
            return pointer
        }
        return eventType
    }
}

//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

extension ListNative where T == dxfg_event_clazz_t {
    func newList() -> UnsafeMutablePointer<dxfg_event_clazz_list_t> {
        let listPointer = UnsafeMutablePointer<dxfg_event_clazz_list_t>.allocate(capacity: 1)
        listPointer.pointee.size = self.size
        listPointer.pointee.elements = self.elements
        return listPointer
    }
}

extension ListNative where T == dxfg_event_type_t {
    func newList() -> UnsafeMutablePointer<dxfg_event_type_list> {
        let listPointer = UnsafeMutablePointer<dxfg_event_type_list>.allocate(capacity: 1)
        listPointer.pointee.size = self.size
        listPointer.pointee.elements = self.elements
        return listPointer
    }
}

extension ListNative where T == dxfg_symbol_t {
    func newList() -> UnsafeMutablePointer<dxfg_symbol_list> {
        let listPointer = UnsafeMutablePointer<dxfg_symbol_list>.allocate(capacity: 1)
        listPointer.pointee.size = self.size
        listPointer.pointee.elements = self.elements
        return listPointer
    }
}

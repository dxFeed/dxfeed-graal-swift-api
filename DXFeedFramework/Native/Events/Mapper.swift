//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

/// Protocol  for mapping unmanaged native events dxfg_event_type_t
protocol Mapper {
    associatedtype TypeAlias
    var type: TypeAlias.Type { get }

    func fromNative(native: UnsafeMutablePointer<dxfg_event_type_t>) throws -> MarketEvent?
    func toNative(event: MarketEvent) throws -> UnsafeMutablePointer<dxfg_event_type_t>?
    func releaseNative(native: UnsafeMutablePointer<dxfg_event_type_t>)
}

extension Mapper {
    func releaseNative(native: UnsafeMutablePointer<dxfg_event_type_t>) {
        native.withMemoryRebound(to: type, capacity: 1) { native in
            native.deinitialize(count: 1)
            native.deallocate()
        }
    }
}

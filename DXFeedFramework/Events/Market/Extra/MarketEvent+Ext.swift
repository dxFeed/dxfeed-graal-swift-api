//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

public protocol ScopingFunctionSupported {
    associatedtype ASelf = Self where ASelf: ScopingFunctionSupported

    func `let`<T>(block: (ASelf) -> T) -> T
    func also(block: (ASelf) -> Void) -> ASelf
}

public extension ScopingFunctionSupported {
    @inline(__always)
    @discardableResult
    func `let`<T>(block: (Self) -> T) -> T {
        return block(self)
    }

    @inline(__always)
    @discardableResult
    func also(block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

extension MarketEvent: ScopingFunctionSupported {}

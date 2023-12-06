//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
@_implementationOnly import graal_api

/// Just box for graal structure.
///
/// Please, override deinit to correct deallocation graal structure
class NativeBox<T> {
    let native: UnsafeMutablePointer<T>
    init(native: UnsafeMutablePointer<T>) {
        self.native = native
    }
}

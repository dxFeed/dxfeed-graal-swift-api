//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

class WeakBox<T> {
    private weak var _value: AnyObject?
    var value: T? {
        return _value as? T
    }
    init(value: T) {
        self._value = value as AnyObject
    }

    func resetValue() {
        _value = nil
    }
}

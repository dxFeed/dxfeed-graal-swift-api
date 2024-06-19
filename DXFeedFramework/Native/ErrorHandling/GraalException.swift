//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Represents errors that occur when calling graal function.
public enum GraalException: Error {
    case undefined
    case fail(message: String, className: String, stack: String)
    case isolateFail(message: String)
    case nullException
}

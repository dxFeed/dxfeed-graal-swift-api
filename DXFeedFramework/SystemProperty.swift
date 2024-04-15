//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// Wrapper over the Java java.lang.System class, contains work with property getter/setter methods.
///
/// In Java world, these properties can be set by passing the "-Dprop=value" argument in command line
/// or calls java.lang.System.setProperty(String key, String value).
/// The location of the imported functions is in the header files "dxfg_system.h"
public class SystemProperty {
    /// Sets the system property indicated by the specified key.
    ///
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public static func setProperty(_ key: String, _ value: String) throws {
        try NativeProperty.setProperty(key, value)
    }
    /// Gets the system property indicated by the specified key.
    public static func getProperty(_ key: String) -> String? {
        return NativeProperty.getProperty(key)
    }
}

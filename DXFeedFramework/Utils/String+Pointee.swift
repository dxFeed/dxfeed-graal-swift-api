//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

extension String {
    public init(pointee: UnsafePointer<CChar>!, default value: String = "") {
        if pointee != nil {
            self =  String(utf8String: pointee) ?? value
        } else {
            self = value
        }
    }

    public init?(nullable pointee: UnsafePointer<CChar>!) {
        if pointee != nil {
            self =  String(utf8String: pointee) ?? ""
        } else {
            return nil
        }
    }

    func toCStringRef() -> UnsafeMutablePointer<CChar> {
        return UnsafeMutablePointer<CChar>(mutating: (self as NSString).utf8String!)
    }

    func toCStringRef() -> UnsafePointer<CChar> {
        return UnsafePointer<CChar>((self as NSString).utf8String!)
    }
}

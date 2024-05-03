//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import SwiftUI

#if os(macOS)
extension Color {
    static let viewBackground = Color.tableBackground
    static let sectionBackground = Color.cellBackground
    static let infoBackground = Color.priceBackground
    static let labelText = Color.text
}
#elseif os(iOS)
extension Color {
    static let viewBackground = Color(UIColor.tableBackground)
    static let sectionBackground = Color(UIColor.cellBackground)
    static let infoBackground = Color(UIColor.priceBackground)
    static let labelText = Color(UIColor.text)
}
#endif

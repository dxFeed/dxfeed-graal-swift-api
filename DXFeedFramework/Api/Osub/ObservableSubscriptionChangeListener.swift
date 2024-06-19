//
//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation


public protocol ObservableSubscriptionChangeListener: AnyObject {
    func symbolsAdded<O>(symbols: Set<O>) where O: Symbol,
                                                O: Hashable

    func symbolsRemoved<O>(symbols: Set<O>) where O: Symbol,
                                                O: Hashable

    func subscriptionClosed()
}

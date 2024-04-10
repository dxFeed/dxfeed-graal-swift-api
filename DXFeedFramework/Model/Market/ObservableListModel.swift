//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

public class ObservableListModel {
    let native: NativeObservableListModel
    private let listeners = ConcurrentWeakHashTable<AnyObject>()

    init(native: NativeObservableListModel) {
        self.native = native
    }

    /// Adds a listener to this order book model.
    /// - Parameters:
    ///   - listener: ``ObservableListModelListener``.
    public func add<O>(listener: O) throws
    where O: ObservableListModelListener,
          O: Hashable {
              try listeners.reader { [weak self] in
                  if $0.count == 0 {
                      try self?.native.addListener(self)
                  }
              }
              listeners.insert(listener)
          }

    /// Removes a listener from this order book model.
    /// - Parameters:
    ///   - listener: ``ObservableListModelListener``.
    public func remove<O>(listener: O)
    where O: ObservableListModelListener,
          O: Hashable {
              listeners.remove(listener)
          }

}

extension ObservableListModel: ObservableListModelListener {
    public func changed(order: [MarketEvent]) {
        listeners.reader { items in
            let enumerator = items.objectEnumerator()
            while let listener = enumerator.nextObject() as? ObservableListModelListener {
                listener.changed(order: order)
            }
        }
    }
}

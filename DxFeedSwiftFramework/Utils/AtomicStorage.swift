//
//  ListenerStorage.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 23.05.23.
//

import Foundation

class AtomicStorage<T: AnyObject> {

    private let lockQueue = DispatchQueue(label: "atomic.storage.queue", attributes: .concurrent)
    private var storage: [T]

    init() {
        self.storage = []
    }
    func append(_ value: T) {
        lockQueue.async(flags: .barrier) { [unowned self] in
            storage.append(value)
        }
    }
    func remove(_ value: T) {
        lockQueue.async(flags: .barrier) { [unowned self] in
            storage.removeAll { $0 === value }
        }
    }
}

//
//  DXFeedSubcription.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 30.05.23.
//

import Foundation

class DXFeedSubcription {
    private let native: NativeSubscription
    fileprivate let events: Set<EventCode>
    deinit {
    }

    internal init(native: NativeSubscription?, events: [EventCode]) throws {
        if let native = native {
            self.native = native
        } else {
            throw UninitializedNativeException.nilValue
        }
        self.events = Set(events)
    }
}

extension DXFeedSubcription: Hashable {
    static func == (lhs: DXFeedSubcription, rhs: DXFeedSubcription) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.events)
    }
}

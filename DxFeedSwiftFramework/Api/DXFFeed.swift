//
//  DXFFeed.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 22.05.23.
//

import Foundation

class DXFFeed {
    private let native: NativeFeed
    deinit {
#warning("TODO: implement it")
    }

    internal init(native: NativeFeed?) throws {
        #warning("TODO: implement it")
        if let native = native {
            self.native = native
        } else {
            throw UninitializedNativeException.nilValue
        }
    }
}

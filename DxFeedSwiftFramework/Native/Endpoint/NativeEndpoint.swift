//
//  NativeEndpoint.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 22.05.23.
//

import Foundation
@_implementationOnly import graal_api

class NativeEndpoint {
    let endpoint: UnsafeMutablePointer<dxfg_endpoint_t>?
    func feed() -> NativeFeed {
#warning("TODO: implement it")
        return NativeFeed()
    }    
    internal init(_ native: UnsafeMutablePointer<dxfg_endpoint_t>) {
        self.endpoint = native
    }
}

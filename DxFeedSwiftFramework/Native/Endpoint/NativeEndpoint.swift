//
//  NativeEndpoint.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 22.05.23.
//

import Foundation
@_implementationOnly import graal_api

class NativeEndpoint {
    let endpoint: UnsafeMutablePointer<dxfg_endpoint_t>!
    
    let listenerCallback: @convention(c) (OpaquePointer?, dxfg_endpoint_state_t, dxfg_endpoint_state_t, UnsafeMutableRawPointer?) -> Void = {_, _, newState, context in
        if let context = context {
            let endpoint: AnyObject = bridge(ptr: context)
            if let listener =  endpoint as? EndpointListener {
#warning("TODO: implement it")
                listener .changeState(old: .connected, new: .connecting)
            }
            print("state changed \(newState.rawValue) \(context)")
        }
    }
    
    
    private lazy var feed: NativeFeed? = {
        let thread = currentThread()
        do {
            let nativeFeed = try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_getFeed(thread, self.endpoint))
            return NativeFeed(feed: nativeFeed)
        } catch {
            print(error)
            return nil
        }
    }()
    
    deinit {
        if let endpoint = self.endpoint {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(thread, &(endpoint.pointee.handler)))
        }
    }
    
    internal init(_ native: UnsafeMutablePointer<dxfg_endpoint_t>) {
        self.endpoint = native
    }
    
    
    func getNativeFeed() -> NativeFeed? {
        return self.feed
    }
    
    func addListener(_ listener: EndpointListener) {
        
    }

}

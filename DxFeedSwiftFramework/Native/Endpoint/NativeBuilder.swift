//
//  NativeBuilder.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 21.03.2023.
//

import Foundation
@_implementationOnly import graal_api

class NativeBuilder {
    let builder: UnsafeMutablePointer<dxfg_endpoint_builder_t>?
    
    deinit {
        
    }
    
    init() throws {
        try self.builder = ErrorCheck.nativeCall(ThreadManager.shared.attachThread(), dxfg_DXEndpoint_newBuilder(ThreadManager.shared.attachThread().thread.pointee))
    }
    
    func isSupporProperty(_ key: String) throws -> Bool {
        let res = try ErrorCheck.nativeCall(ThreadManager.shared.attachThread(), dxfg_DXEndpoint_Builder_supportsProperty(ThreadManager.shared.attachThread().thread.pointee, self.builder, key.cString(using: .utf8)))
        
        return res != 0
    }
    
    func withRole(_ role: DXFEndpoint.Role) throws {
        //TODO: add set role
    }
    
    func withProperty(_ key: String, _ value: String) throws {
        try _ = ErrorCheck.nativeCall(ThreadManager.shared.attachThread(), dxfg_DXEndpoint_Builder_withProperty(ThreadManager.shared.attachThread().thread.pointee, self.builder, key.cString(using: .utf8), value.cString(using: .utf8)))
    }
}

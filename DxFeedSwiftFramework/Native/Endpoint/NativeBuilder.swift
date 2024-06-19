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
    var role = Role.feed
    deinit {
#warning("TODO: implement it")
    }

    init() throws {
        let thread = currentThread()

        self.builder = try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_newBuilder(thread))
    }

    func isSupporProperty(_ key: String) throws -> Bool {
        let thread =  currentThread()

        let res = try ErrorCheck.nativeCall(thread,
                                            dxfg_DXEndpoint_Builder_supportsProperty(thread,
                                                                                     self.builder,
                                                                                     key.cString(using: .utf8)))
        return res != 0
    }

    func withRole(_ role: Role) throws -> Bool {
        let thread =  currentThread()

        let res = try ErrorCheck.nativeCall(thread,
                                            dxfg_DXEndpoint_Builder_withRole(thread,
                                                                             builder,
                                                                             dxfg_endpoint_role_t(role.rawValue)
                                                                            )
        )
        return res != 0
    }

    func withProperty(_ key: String, _ value: String) throws {
        let thread =  currentThread()
         _ = try ErrorCheck.nativeCall(thread,
                                       dxfg_DXEndpoint_Builder_withProperty(thread,
                                                                           self.builder,
                                                                           key.cString(using: .utf8),
                                                                           value.cString(using: .utf8)))
    }

    func build() throws -> NativeEndpoint {
        let thread =  currentThread()
        let value = try ErrorCheck.nativeCall(thread, dxfg_DXEndpoint_Builder_build(thread, builder))
        return NativeEndpoint(value)
    }
}

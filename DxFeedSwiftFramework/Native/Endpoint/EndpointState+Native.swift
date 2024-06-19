//
//  EndpointState+Native.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 24.05.23.
//

import Foundation
@_implementationOnly import graal_api

extension EndpointState {
    static func convert(_ state: dxfg_endpoint_state_t) -> EndpointState? {
        switch state {
        case DXFG_ENDPOINT_STATE_CLOSED:
            return .closed
        case DXFG_ENDPOINT_STATE_CONNECTED:
            return .connected
        case DXFG_ENDPOINT_STATE_CONNECTING:
            return .connecting
        case DXFG_ENDPOINT_STATE_NOT_CONNECTED:
            return .notConnected
        default:
            return nil
        }
    }
}

//
//  InstrumentProfileConnectionState+ext.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 01.09.23.
//

import Foundation
@_implementationOnly import graal_api

extension InstrumentProfileConnectionState {
    static func convert(_ state: dxfg_ipf_connection_state_t) -> InstrumentProfileConnectionState? {
        switch state {
        case DXFG_IPF_CONNECTION_STATE_NOT_CONNECTED:
            return .closed
        case DXFG_IPF_CONNECTION_STATE_CONNECTING:
            return .connected
        case DXFG_IPF_CONNECTION_STATE_CONNECTED:
            return .connecting
        case DXFG_IPF_CONNECTION_STATE_COMPLETED:
            return .notConnected
        case DXFG_IPF_CONNECTION_STATE_CLOSED:
            return .notConnected
        default:
            return nil
        }
    }
}

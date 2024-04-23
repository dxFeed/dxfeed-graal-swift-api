//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation
@_implementationOnly import graal_api

extension Role {
    func toNatie() -> dxfg_endpoint_role_t {
        switch self {
        case .feed:
            return DXFG_ENDPOINT_ROLE_FEED
        case .onDemandFeed:
            return DXFG_ENDPOINT_ROLE_ON_DEMAND_FEED
        case .streamFeed:
            return DXFG_ENDPOINT_ROLE_STREAM_FEED
        case .publisher:
            return DXFG_ENDPOINT_ROLE_PUBLISHER
        case .streamPublisher:
            return DXFG_ENDPOINT_ROLE_STREAM_PUBLISHER
        case .localHub:
            return DXFG_ENDPOINT_ROLE_LOCAL_HUB
        }
    }

    static func fromNative(_ native: dxfg_endpoint_role_t) -> Role {
        switch native {
        case DXFG_ENDPOINT_ROLE_FEED:
            return .feed
        case DXFG_ENDPOINT_ROLE_ON_DEMAND_FEED:
            return .onDemandFeed
        case DXFG_ENDPOINT_ROLE_STREAM_FEED:
            return .streamFeed
        case DXFG_ENDPOINT_ROLE_PUBLISHER:
            return .publisher
        case DXFG_ENDPOINT_ROLE_STREAM_PUBLISHER:
            return .streamPublisher
        case DXFG_ENDPOINT_ROLE_LOCAL_HUB:
            return .localHub
        default:
            fatalError("Try to initialize Role with wrong value \(native)")
        }
    }
}

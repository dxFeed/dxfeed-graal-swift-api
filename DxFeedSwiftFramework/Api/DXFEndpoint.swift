//
//  DXFEndpoint.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 20.03.2023.
//

import Foundation

class DXFEndpoint {
    enum Role {
        case feed
        case onDemandFeed
        case streamFeed
        case publisher
        case streamPublisher
        case localHub
    }
    class Builder {
        var role: Role? = nil
        var props = [String: String]()
        private lazy var nativeBuilder: NativeBuilder? = {
            try? NativeBuilder()
        }()
        
        fileprivate init() {
            
        }
        
        func withRole(_ role: Role) throws -> Self {
            self.role = role
            try nativeBuilder?.withRole(role)
            return self
        }
        
        func withProperty(_ key: String, _ value: String) throws -> Self {
            props[key] = value
            try nativeBuilder?.withProperty(key, value)
            return self
        }
        
        func build() -> DXFEndpoint {
            return DXFEndpoint()
        }
        
    }
    enum Property: String {
        case name                          = "name"
        case properties                    = "dxfeed.properties"
        case address                       = "dxfeed.address"
        case user                          = "dxfeed.user"
        case password                      = "dxfeed.password"
        case threadPoolSize                = "dxfeed.threadPoolSize"
        case aggregationPeriod             = "dxfeed.aggregationPeriod"
        case wildcardEnable                = "dxfeed.wildcard.enable"
        case publisherProperties           = "dxpublisher.properties"
        case publisherThreadPoolSize       = "dxpublisher.threadPoolSize"
        case eventTime                     = "dxendpoint.eventTime"
        case storeEverything               = "dxendpoint.storeEverything"
        case schemeNanoTime                = "dxscheme.nanoTime"
        case schemeEnabledPropertyPrefix   = "dxscheme.enabled"
    }
    static func builder() -> Builder {
        Builder()
    }
}



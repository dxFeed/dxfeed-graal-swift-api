//
//  DXFEndpoint.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 20.03.2023.
//

import Foundation

typealias Role = DXFEndpoint.Role

class DXFEndpoint {

    enum Role: UInt32 {
        case feed = 0
        case onDemandFeed
        case streamFeed
        case publisher
        case streamPublisher
        case localHub

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
    private let endpointNative: NativeEndpoint
    private let role: Role
    private let name: String
    private lazy var feed: DXFFeed? = {
        try? DXFFeed(native: endpointNative.getNativeFeed())
    }()
    private lazy var publisher = {
        DXFPublisher()
    }()
    private var listeners = [EndpointListener]()

    fileprivate init(native: NativeEndpoint, role: Role, name: String) throws {
        self.endpointNative = native
        self.role = role
        self.name = name
        try native.addListener(self)
    }
    public static func builder() -> Builder {
        Builder()
    }
    public func getFeed() -> DXFFeed? {
        return self.feed
    }
    public func connect(_ address: String) throws {
        try self.endpointNative.connect(address)
    }
    public func disconnect() throws {
        try self.endpointNative.disconnect()
    }
    public func appendListener(_ listener: EndpointListener) {
        listeners.append(listener)
    }
}

class Builder {
    var role = Role.feed
    var props = [String: String]()

    var instancesNumerator = Int64(0)

    private lazy var nativeBuilder: NativeBuilder? = {
        try? NativeBuilder()
    }()

    deinit {
    }

    fileprivate init() {

    }

    func withRole(_ role: Role) throws -> Self {
        self.role = role
        _ = try nativeBuilder?.withRole(role)
        return self
    }

    func withProperty(_ key: String, _ value: String) throws -> Self {
        props[key] = value
        try nativeBuilder?.withProperty(key, value)
        return self
    }

    func build() throws -> DXFEndpoint {
        return try DXFEndpoint(native: try nativeBuilder!.build(), role: role, name: getOrCreateEndpointName())
    }

    private func getOrCreateEndpointName() -> String {
        if let name = props[DXFEndpoint.Property.name.rawValue] {
            return name
        }
        let value = OSAtomicIncrement64(&instancesNumerator)
        return "qdnet_\(value == 0 ? "" : "-\(value)")"
    }
}

extension DXFEndpoint: EndpointListener {
    func changeState(old: EndpointState, new: EndpointState) {
        print("\(self) change state \(old) to \(new)")
        listeners.forEach { $0.changeState(old: old, new: new) }
    }
}

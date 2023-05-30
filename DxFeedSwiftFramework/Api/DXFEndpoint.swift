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

    enum Property: String, CaseIterable {
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
        case schemeEnabledPropertyPrefix   = "dxscheme.enabled."
    }
    private let endpointNative: NativeEndpoint
    // public let = private set + public get
    public let role: Role
    private let name: String
    private lazy var feed: DXFFeed? = {
        try? DXFFeed(native: endpointNative.getNativeFeed())
    }()
    private lazy var publisher = {
        DXFPublisher()
    }()

    private var observersSet = ConcurrentSet<AnyHashable>()
    private var observers: [DXFEndpointObserver] {
        return observersSet.reader { $0.compactMap { value in value as? DXFEndpointObserver } }
    }

    private static var instances = [Role: DXFEndpoint]()

    fileprivate init(native: NativeEndpoint, role: Role, name: String) throws {
        self.endpointNative = native
        self.role = role
        self.name = name
        try native.addListener(self)
    }

    func add<O>(_ observer: O)
    where O: DXFEndpointObserver,
          O: Hashable {
        observersSet.insert(observer)
    }

    func remove<O>(_ observer: O)
    where O: DXFEndpointObserver,
          O: Hashable {
        observersSet.remove(observer)
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

    public func reconnect() throws {
        try self.endpointNative.reconnect()
    }

    public func disconnect() throws {
        try self.endpointNative.disconnect()
    }

    public func disconnectAndClear() throws {
        try self.endpointNative.disconnectAndClear()
    }

    public func close() throws {
        try self.endpointNative.close()
    }

    public func set(password: String) throws -> Self {
        try endpointNative.set(password: password)
        return self
    }

    public func set(userName: String) throws -> Self {
        try endpointNative.set(userName: userName)
        return self
    }

    public func awaitProcessed() throws {
        try endpointNative.awaitProcessed()
    }

    public func awaitNotConnected() throws {
        try endpointNative.awaitNotConnected()
    }

    public func getState() throws -> DXFEndpointState {
        return try endpointNative.getState()
    }

    public static func create(_ role: Role) throws -> DXFEndpoint {
        return try Builder().withRole(role).build()
    }

    public static func getInstance(_ role: Role) throws -> DXFEndpoint {
        defer {
            objc_sync_exit(self)
        }
        objc_sync_enter(self)
        if let instance = instances[role] {
            return instance
        } else {
            let instance = try create(role)
            instances[role] = instance
            return instance
        }
    }

// only for testing
    func callGC() throws {
        try endpointNative.callGC()
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

    func isSupported(property: String) throws -> Bool {
        return try nativeBuilder?.isSuppored(property: property) ?? false
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
    func changeState(old: DXFEndpointState, new: DXFEndpointState) {
        print("\(self) change state \(old) to \(new)")
        observers.forEach { $0.endpointDidChangeState(old: old, new: new) }
    }
}

//
//  DXEndpoint.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 20.03.2023.
//

import Foundation

public typealias Role = DXEndpoint.Role

public class DXEndpoint {

   public  enum Role: UInt32 {
        case feed = 0
        case onDemandFeed
        case streamFeed
        case publisher
        case streamPublisher
        case localHub

    }

    public enum Property: String, CaseIterable {
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
    //Extra properties are wrappers aroung string. Build.isSupported returns false for that.
    public enum ExtraPropery: String, CaseIterable {
        case heartBeatTimeout              = "com.devexperts.connector.proto.heartbeatTimeout"
    }
    private let endpointNative: NativeEndpoint
    // public let = private set + public get
    public let role: Role
    private let name: String
    private lazy var feed: DXFeed? = {
        try? DXFeed(native: endpointNative.getNativeFeed())
    }()
    private lazy var publisher = {
        DXPublisher()
    }()

    private var observersSet = ConcurrentSet<AnyHashable>()
    private var observers: [DXEndpointObserver] {
        return observersSet.reader { $0.compactMap { value in value as? DXEndpointObserver } }
    }

    private static var instances = [Role: DXEndpoint]()

    fileprivate init(native: NativeEndpoint, role: Role, name: String) throws {
        self.endpointNative = native
        self.role = role
        self.name = name
        try native.addListener(self)
    }

    public func add<O>(_ observer: O)
    where O: DXEndpointObserver,
          O: Hashable {
        observersSet.insert(observer)
    }

    public func remove<O>(_ observer: O)
    where O: DXEndpointObserver,
          O: Hashable {
        observersSet.remove(observer)
    }

    public static func builder() -> Builder {
        Builder()
    }
    public func getFeed() -> DXFeed? {
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

    public func getState() throws -> DXEndpointState {
        return try endpointNative.getState()
    }

    public static func create(_ role: Role) throws -> DXEndpoint {
        return try Builder().withRole(role).build()
    }

    public static func getInstance(_ role: Role) throws -> DXEndpoint {
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

public class Builder {
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

    public func withRole(_ role: Role) throws -> Self {
        self.role = role
        _ = try nativeBuilder?.withRole(role)
        return self
    }

    public func isSupported(property: String) throws -> Bool {
        return try nativeBuilder?.isSuppored(property: property) ?? false
    }

    public func withProperty(_ key: String, _ value: String) throws -> Self {
        props[key] = value
        try nativeBuilder?.withProperty(key, value)
        return self
    }

    public func build() throws -> DXEndpoint {
        return try DXEndpoint(native: try nativeBuilder!.build(), role: role, name: getOrCreateEndpointName())
    }

    private func getOrCreateEndpointName() -> String {
        if let name = props[DXEndpoint.Property.name.rawValue] {
            return name
        }
        let value = OSAtomicIncrement64(&instancesNumerator)
        return "qdnet_\(value == 0 ? "" : "-\(value)")"
    }
}

extension DXEndpoint: EndpointListener {
    func changeState(old: DXEndpointState, new: DXEndpointState) {
        observers.forEach { $0.endpointDidChangeState(old: old, new: new) }
    }
}

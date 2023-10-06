//
//  DXEndpoint.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 20.03.2023.
//

import Foundation

public typealias Role = DXEndpoint.Role

/// Manages network connections to ``DXFeed`` or ``DXPublisher``
///
/// Porting a Java class com.dxfeed.api.DXEndpoint.
///
/// For more details see  https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXEndpoint.html
/// There are ready-to-use singleton instances that are available with ``DXEndpoint/getInstance(_:)`` method as wel as
/// factory method ``DXEndpoint/create(_:)``, and a number of configuration methods.
///
/// Advanced properties can be configured with ``Builder``
///
/// Threads and locks
///
/// This class is thread-safe and can be used concurrently from multiple threads without external synchronization.
///
/// Example
///
///     let endpoint = try DXEndpoint.create().set(userName: "demo").set(password: "demo")
///     .connect("demo.dxfeed.com:7300").getFeed()
///
public class DXEndpoint {

    /// A list of endpoint roles.
    public enum Role: UInt32 {
        /// Feed endpoint connects to the remote data feed provider
        /// and is optimized for real-time or delayed data processing (**this is a default role**).
        ///  Method ``DXEndpoint/getFeed()`` returns feed object that subscribes
        /// to the remote data feed provider and receives events from it.
        /// When event processing threads cannot keep up (don't have enough CPU time), data is dynamically conflated
        /// to minimize latency between received events and their processing time.
        case feed = 0
        /// ``onDemandFeed`` endpoint is similar to ``feed``, but it is designed to be used with
        /// OnDemandService for historical data replay only.
        case onDemandFeed
        /// ``streamFeed`` endpoint is similar to ``feed``
        /// and also connects to the remote data feed provider, is designed for bulk parsing of data from files.
        /// Method ``DXEndpoint/getFeed()`` returns feed object that subscribes
        /// to the data from the opened files and receives events from them.
        /// Events from the files are not conflated, are not skipped, and are processed as fast as possible.
        case streamFeed
        /// ``publisher`` endpoint connects to the remote publisher hub (also known as multiplexor) or
        /// creates a publisher on the local host.
        /// ``DXEndpoint/getPublisher()``  method returns a publisher object
        /// that publishes events to all connected feeds.
        case publisher
        /// ``streamPublisher`` endpoint is similar to ``publisher``
        /// and also connects to the remote publisher hub, but is designed for bulk publishing of data.
        /// ``DXEndpoint/getPublisher()`` method returns a publisher object that publishes events
        /// to all connected feeds.
        /// Published events are not conflated, are not skipped, and are processed as fast as possible.
        case streamPublisher
        /// ``localHub`` endpoint is a local hub without ability to establish network connections.
        /// Events that are published via ``DXEndpoint/getPublisher()`` are delivered to local
        /// ``DXEndpoint/getFeed()`` only.
        case localHub

    }

    /// Defines property for ``DXEndpoint``
    public enum Property: String, CaseIterable {
        /// Defines property for endpoint name that is used to distinguish multiple endpoints
        /// in the same JVM in logs and in other diagnostic means.
        /// Use ``Builder/withProperty(_:_:)`` method.
        /// This property is also changed by ``Builder/withName(_:)`` method.
        case name                          = "name"
        /// Defines path to a file with properties for an endpoint with role  ``Role-swift.enum/feed``
        ///  or ``Role-swift.enum/onDemandFeed``
        /// This file must be in the [Java properties file format](https://en.wikipedia.org/wiki/.properties) .
        /// This property can also be set using  ``SystemProperty/setProperty(_:_:)``,
        /// as the default property for all instances ``DXEndpoint`` with ``Role-swift.enum/feed`` or
        /// ``Role-swift.enum/onDemandFeed`` role.
        /// When the path to this properties file not provided ``SystemProperty/setProperty(_:_:)``
        /// and ``Builder/withProperty(_:_:)``,
        /// the file "dxfeed.properties" loaded from current runtime directory.
        /// It means that the corresponding file can be placed into the current directory with any need
        /// to specify additional properties.
        case properties                    = "dxfeed.properties"
        /// Defines default connection address for an endpoint with role ``Role-swift.enum/feed``
        /// or ``Role-swift.enum/onDemandFeed``.
        /// Connection is established to this address by role ``Role-swift.enum/feed``
        /// as soon as endpoint is created.
        /// By default, without this property, connection is not established until ``DXEndpoint/connect(_:)``
        ///  is invoked.
        /// Credentials for access to premium services may be configured with ``user`` and ``password``
        case address                       = "dxfeed.address"
        /// Defines default user name for an endpoint with role  ``Role-swift.enum/feed``
        /// or ``Role-swift.enum/onDemandFeed``
        case user                          = "dxfeed.user"
        /// Defines default password for an endpoint with role
        /// ``Role-swift.enum/feed`` or ``Role-swift.enum/onDemandFeed``
        case password                      = "dxfeed.password"
        /// Defines thread pool size for an endpoint with role ``Role-swift.enum/feed``
        /// By default, the thread pool size is equal to the number of available processors.
        case threadPoolSize                = "dxfeed.threadPoolSize"
        /// Defines data aggregation period an endpoint with role ``Role-swift.enum/feed`` that
        /// limits the rate of data notifications. For example, setting the value of this property
        /// to "0.1s" limits notification to once every 100ms (at most 10 per second).
        case aggregationPeriod             = "dxfeed.aggregationPeriod"
        /// Set this property to **true** to turns on wildcard support.
        /// By default, the endpoint does not support wildcards. This property is needed for ``WildcardSymbol``
        /// support and for the use of "tape:..." address in ``DXPublisher``.
        case wildcardEnable                = "dxfeed.wildcard.enable"
        /// Defines path to a file with properties for an endpoint with role ``Role-swift.enum/feed``
        /// This file must be in the [Java properties file format](https://en.wikipedia.org/wiki/.properties)
        /// This property can also be set using ``SystemProperty/setProperty(_:_:)``
        /// as the default property for all instances ``DXEndpoint`` with ``Role-swift.enum/publisher``
        /// When the path to this properties file not provided ``SystemProperty/setProperty(_:_:)``
        /// and  ``Builder/withProperty(_:_:)``
        /// the file "dxpublisher.properties" loaded from current runtime directory.
        /// It means that the corresponding file can be placed into the current directory with any need
        /// to specify additional properties.
        case publisherProperties           = "dxpublisher.properties"
        /// Defines default connection address for an endpoint with role ``Role-swift.enum/publisher``
        /// Connection is established to this address as soon as endpoint is created.
        /// By default, connection is not established until ``DXEndpoint/connect(_:)`` is invoked.
        case publisherAddressProperty      = "dxpublisher.address"
        /// Defines thread pool size for an endpoint with role ``Role-swift.enum/publisher``
        /// By default, the thread pool size is equal to the number of available processors.
        case publisherThreadPoolSize       = "dxpublisher.threadPoolSize"
        /// Set this property to **true** to enable ``IEventType/eventTime``support.
        /// By default, the endpoint does not support event time.
        /// The event time is available only when the corresponding ``DXEndpoint``
        /// is created with this property and the data source has embedded event times.
        /// This is typically **true** only for data events that are read from historical tape files.
        /// Events that are coming from a network connections do not have an embedded event time
        /// information and event time is not available for them anyway.
        case eventTime                     = "dxendpoint.eventTime"
        /// Set this property to to store all  ``ILastingEvent``
        /// and ``ILastingEvent`` events
        /// even when there is no subscription on them. By default, the endpoint stores only events from subscriptions.
        /// It works in the same way both for ``DXFeed`` and ``DXPublisher``.
        /// Use this property with extreme care, since API does not currently provide any means to remove those events
        /// from the storage and there might be an effective memory leak
        /// if the spaces of symbols on which events are published grows without bound.
        case storeEverything               = "dxendpoint.storeEverything"
        /// Set this property to **true** to turn on nanoseconds precision business time.
        /// By default, this feature is turned off.
        /// Business time in most events is available with millisecond precision by default,
        /// while ``Quote`` events business ``Quote/time``
        /// is available with seconds precision.
        /// This method provides a higher-level control than turning on individual properties that are responsible
        /// for nano-time via ``DXEndpoint/Property/schemeEnabledPropertyPrefix``.
        /// The later can be used to override of fine-time nano-time support for individual fields.
        /// Setting this property to **true** is essentially equivalent to setting:
        ///     dxscheme.enabled.Sequence=\*
        ///     dxscheme.enabled.TimeNanoPart=\*
        case schemeNanoTime                = "dxscheme.nanoTime"
        /// Defines whether a specified field from the scheme should be enabled instead of it's default behaviour.
        /// Use it according to following format:
        /// dxscheme.enabled.field_property_name=event_name_mask_glob
        /// For example, **dxscheme.enabled.TimeNanoPart=Trade** enables NanoTimePart
        /// internal field only in Trade events.
        /// There is a shortcut for turning on nano-time support using ``DXEndpoint/Property/schemeNanoTime``
        case schemeEnabledPropertyPrefix   = "dxscheme.enabled."
    }

    /// Defines extra property for ``DXEndpoint``. This properties can't check using
    /// ``Builder/isSupported(_:)``(always return false)
    public enum ExtraPropery: String, CaseIterable {
        /// Defines time out for outcoming connection. Example of value: "10s"
        case heartBeatTimeout              = "com.devexperts.connector.proto.heartbeatTimeout"
    }
    /// Endpoint native wrapper.
    private let endpointNative: NativeEndpoint
    /// The endpoint role.
    /// public let = public getter for constant value
    public let role: Role
    /// The endpoint name.
    /// /// public let = public getter for constant value
    public let name: String
    /// Lazy initialization of the ``DXFeed`` instance.
    private lazy var feed: DXFeed? = {
        try? DXFeed(native: endpointNative.getNativeFeed())
    }()
    /// Lazy initialization of the ``DXPublisher`` instance.
    private lazy var publisher = {
        DXPublisher()
    }()
    /// A list of state change listeners callback. observersSet - not typed variable(as storage).
    private var observersSet = ConcurrentWeakHashTable<DXEndpointObserver>()

    private static var instances = [Role: DXEndpoint]()

    deinit {
        try? close()
    }

    fileprivate init(native: NativeEndpoint, role: Role, name: String) throws {
        self.endpointNative = native
        self.role = role
        self.name = name
        try native.addListener(self)
    }
    /// Adds listener that is notified about changes in ``getState()`` property.
    /// Installed listener can be removed with ``remove(_:)`` method.
    public func add<O>(observer: O)
    where O: DXEndpointObserver,
          O: Hashable {
              observersSet.insert(observer)
          }
    /// Removes listener that is notified about changes in ``getState()`` property.
    /// It removes the listener that was previously installed with ``add(observer:)`` method.
    public func remove<O>(_ observer: O)
    where O: DXEndpointObserver,
          O: Hashable {
              observersSet.remove(observer)
          }
    /// Creates new ``Builder`` instance.
    /// Use ``Builder/build()`` to build an instance of ``DXEndpoint`` when
    /// all configuration properties were set.
    /// - Returns: The created ``Builder`` instance.
    public static func builder() -> Builder {
        Builder()
    }
    /// Gets ``DXFeed`` that is associated with this endpoint.
    /// - Returns: ``DXFeed``
    public func getFeed() -> DXFeed? {
        return self.feed
    }
    /// Gets ``DXPublisher`` that is associated with this endpoint.
    /// - Returns: ``DXPublisher``
    public func getPublisher() -> DXPublisher? {
        return self.publisher
    }
    /// Connects to the specified remote address.
    ///
    /// Previously established connections are closed if
    /// the new address is different from the old one.
    /// This method does nothing if address does not change or if this endpoint is ``DXEndpointState/closed``
    /// The endpoint ``DXEndpointState`` immediately becomes ``DXEndpointState/connecting`` otherwise.
    /// The address string is provided with the market data vendor agreement.
    /// Use "demo.dxfeed.com:7300" for a demo quote feed.
    ///     Examples:  "host:port" to establish a TCP/IP connection.
    ///     ":port" to listen for a TCP/IP connection with a plain socket connector
    ///     (good for up to a few hundred of connections).
    /// For premium services access credentials must be configured before invocation of ``connect(_:)`` method
    /// using ``set(userName:)`` and ``set(password:)`` methods.
    /// **This method does not wait until connection actually gets established**. The actual connection establishment
    /// happens asynchronously after the invocation of this method. However, this method waits until notification
    /// about state transition from ``DXEndpointState/notConnected`` to ``DXEndpointState/connecting``
    /// gets processed by all ``DXEndpointObserver`` that were installed via
    /// ``add(observer:)`` method.
    /// - Parameters:
    ///   - address: The data source address.
    /// - Returns: ``DXEndpoint``
    /// - Throws: GraalException. Rethrows exception from Java.
    @discardableResult public func connect(_ address: String) throws -> Self {
        try self.endpointNative.connect(address)
        return self
    }
    /// Terminates all established network connections and initiates connecting again with the same address.
    ///
    /// The effect of the method is alike to invoking ``disconnect()`` and ``connect(_:)``
    /// with the current address, but internal resources used for connections may be reused by implementation.
    /// TCP connections with multiple target addresses will try switch to an alternative address, configured
    /// reconnect timeouts will apply.
    ///
    /// **Note:** The method will not connect endpoint that was not initially connected with
    /// ``connect(_:)`` method or was disconnected with ``disconnect()``  method.
    /// The method initiates a short-path way for reconnecting, so whether observers will have a chance to see
    /// an intermediate state ``DXEndpointState/notConnected`` depends on the implementation.
    /// - Throws: GraalException. Rethrows exception from Java.recore
    public func reconnect() throws {
        try self.endpointNative.reconnect()
    }
    /// Terminates all remote network connections.
    ///
    /// This method does nothing if this endpoint is ``DXEndpointState/closed``
    /// The endpoint ``getState()`` immediately becomes ``DXEndpointState/notConnected`` otherwise.
    /// This method does not release all resources that are associated with this endpoint.
    /// Use ``close()`` or ``closeAndAWaitTermination()`` methods to release all resources.
    /// - Throws: GraalException. Rethrows exception from Java.recore
    public func disconnect() throws {
        try self.endpointNative.disconnect()
    }
    /// Terminates all remote network connections and clears stored data.
    ///
    /// This method does nothing if this endpoint is``DXEndpointState/closed``.
    /// The endpoint``getState()`` immediately becomes``DXEndpointState/notConnected`` otherwise.
    /// This method does not release all resources that are associated with this endpoint.
    /// Use ``close()`` or ``closeAndAWaitTermination()`` methods to release all resources.
    /// - Throws: GraalException. Rethrows exception from Java.recore
    public func disconnectAndClear() throws {
        try self.endpointNative.disconnectAndClear()
    }
    /// Closes this endpoint.
    ///
    /// All network connection are terminated as with ``disconnect()``
    /// method and no further connections can be established.
    /// The endpoint ``getState()`` immediately becomes ``DXEndpointState/closed``.
    /// - Throws: GraalException. Rethrows exception from Java.recore
    public func close() throws {
        try self.endpointNative.close()
    }
    /// Closes this endpoint and wait until all pending data processing tasks are completed.
    /// This  method performs the same actions as close ``close()``, but also awaits
    /// termination of all outstanding data processing tasks. It is designed to be used
    /// with ``Role-swift.enum/streamFeed`` role after ``awaitNotConnected()`` method returns
    /// to make sure that file was completely processed.
    ///
    /// This method is blocking.
    ///
    /// This method ensures that ``DXEndpoint`` can be safely garbage-collected
    /// when all outside references to it are lost.
    public func closeAndAWaitTermination() throws {
        try self.endpointNative.closeAndAWaitTermination()
    }
    /// Changes password for this endpoint.
    /// This method shall be called before ``connect(_:)`` together
    /// with ``set(userName:)`` to configure service access credentials.
    /// </summary>
    /// <param name="password">The user password.</param>
    /// <returns>Returns this ``DXEndpoint``.</returns>
    /// <exception cref="ArgumentNullException">If password is null.</exception>
    public func set(password: String) throws -> Self {
        try endpointNative.set(password: password)
        return self
    }
    /// Changes user name for this endpoint.
    /// This method shall be called before ``connect(_:)`` together
    /// with ``set(password:)`` to configure service access credentials.
    /// </summary>
    /// <param name="user">The user name.</param>
    /// <returns>Returns this ``DXEndpoint``.</returns>
    /// <exception cref="ArgumentNullException">If user is null.</exception>
    public func set(userName: String) throws -> Self {
        try endpointNative.set(userName: userName)
        return self
    }
    /// Waits until this endpoint stops processing data (becomes quiescent).
    ///
    /// This is important when writing data to file via "tape:..." connector to make sure that
    /// all published data was written before closing this endpoint.
    /// **This method is blocking.**
    /// - Throws: GraalException. Rethrows exception from Java.recore
    public func awaitProcessed() throws {
        try endpointNative.awaitProcessed()
    }

    /// Waits while this endpoint ``getState()`` becomes ``DXEndpointState/notConnected`` or
    /// ``DXEndpointState/closed``. It is a signal that any files that were opened with
    /// ``connect(_:)`` with parameter "file:..."  method were finished reading, but not necessary were completely
    /// processed by the corresponding subscription listeners. Use ``closeAndAWaitTermination()`` after
    /// this method returns to make sure that all processing has completed.
    /// **This method is blocking.**
    /// - Throws: GraalException. Rethrows exception from Java.recore
    public func awaitNotConnected() throws {
        try endpointNative.awaitNotConnected()
    }

    /// Gets the ``DXEndpointState`` of this endpoint.
    /// - Returns: ``DXEndpointState``
    /// - Throws: GraalException. Rethrows exception from Java.recore
    public func getState() throws -> DXEndpointState {
        return try endpointNative.getState()
    }
    /// Creates an endpoint with a role.
    /// - Parameters:
    ///     - role: Role for endpoint. Default: ``Role-swift.enum/feed``
    /// - Returns: The created ``DXEndpoint`` instance.
    /// - Throws: GraalException. Rethrows exception from Java.
    public static func create(_ role: Role = .feed) throws -> DXEndpoint {
        return try Builder().withRole(role).build()
    }

    /// Gets a default application-wide singleton instance of DXEndpoint with a ``Role-swift.enum/feed`` role.
    /// Most applications use only a single data-source and should rely on this method to get one.
    /// - Returns: Returns singleton instance of ``DXEndpoint``
    /// - Throws: GraalException. Rethrows exception from Java.
    public static func getInstance(_ role: Role = .feed) throws -> DXEndpoint {
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
}

/// Builder class for ``DXEndpoint`` that supports additional configuration properties.
///
/// Porting a Java class com.dxfeed.api.DXEndpoint.Builder.
/// For more details
/// see [Javadoc](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXEndpoint.Builder.html)
///
/// The ``build()`` method tries to load the default property file for the ``DXEndpoint/Role-swift.enum/feed``,
/// ``DXEndpoint/Role-swift.enum/onDemandFeed`` and ``DXEndpoint/Role-swift.enum/publisher`` role.
///
/// The default properties file is loaded only if there are no system properties (``SystemProperty``)
/// or user properties (``withProperty(_:_:)``) set with the same key
/// (``DXEndpoint/Property/properties``, ``DXEndpoint/Property/publisherProperties``)
/// and the file exists and is readable.
///
/// This file must be in the [Java properties file format](https://en.wikipedia.org/wiki/.properties)
///
/// **Endpoint name**
///
/// If no endpoint name has been specified (``withName(_:)``), the default name will be used.
/// The default name includes a counter that increments each time an endpoint is created ("qdnet", "qdnet-1", etc.).
/// To get the name of the created endpoint, call the ``DXEndpoint/name``.
///
/// **Threads and locks**
///
/// This class is thread-safe and can be used concurrently from multiple threads without external synchronization.
/// 
public class Builder {
    var role = Role.feed
    var props = [String: String]()

    /// A counter that is incremented every time an endpoint is created.
    var instancesNumerator = Int64(0)

    private lazy var nativeBuilder: NativeBuilder? = {
        try? NativeBuilder()
    }()

    deinit {
    }

    fileprivate init() {

    }
    /// Changes name that is used to distinguish multiple ``DXEndpoint``
    /// in the same in logs and in other diagnostic means.
    /// This is a shortcut for
    /// ``withProperty(_:_:)`` with ``DXEndpoint/Property/name``
    /// - Parameters:
    ///   - name: The endpoint name.
    /// - Returns: Returns this ``Builder``
    /// - Throws: GraalException. Rethrows exception from Java.
    public func withName(_ name: String) throws -> Self {
        return try withProperty(DXEndpoint.Property.name.rawValue, name)
    }

    /// Sets role for the created ``DXEndpoint``
    /// Default role is ``DXEndpoint/Role-swift.enum/feed``
    /// - Parameters:
    ///   - role: The endpoint role ``DXEndpoint/Role-swift.enum``.
    /// - Returns: Returns this ``Builder``
    /// - Throws: GraalException. Rethrows exception from Java.
    public func withRole(_ role: Role) throws -> Self {
        self.role = role
        _ = try nativeBuilder?.withRole(role)
        return self
    }

    /// Checks if the corresponding property key is supported.
    /// - Parameters:
    ///   - proeprty: Property name
    /// - Returns: Returns Bool
    /// - Throws: GraalException. Rethrows exception from Java.
    public func isSupported(_ property: String) throws -> Bool {
        return try nativeBuilder?.isSuppored(property: property) ?? false
    }

    /// Sets the specified property. Unsupported properties are ignored
    /// - Parameters:
    ///   - key: Property name
    ///   - value: Property value
    /// - Returns: Returns this ``Builder``
    /// - Throws: GraalException. Rethrows exception from Java.
    public func withProperty(_ key: String, _ value: String) throws -> Self {
        props[key] = value
        try nativeBuilder?.withProperty(key, value)
        return self
    }
    /// Builds ``DXEndpoint`` instance.
    /// This method tries to load default properties file.
    /// - Returns: Returns this ``DXEndpoint``
    /// - Throws: GraalException. Rethrows exception from Java.
    public func build() throws -> DXEndpoint {
        return try DXEndpoint(native: try nativeBuilder!.build(), role: role, name: getOrCreateEndpointName())
    }
    /// Gets or creates an endpoint name.
    /// If there is no ``DXEndpoint/Property/name`` in the user-defined properties,
    /// it returns a default name that includes a counter that increments each time an endpoint is created.
    /// - Returns: New string name
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
        observersSet.reader {
            let enumerator = $0.objectEnumerator()
            while let observer = enumerator.nextObject() as? DXEndpointObserver {
                observer.endpointDidChangeState(old: old, new: new)
            }
        }
    }
}

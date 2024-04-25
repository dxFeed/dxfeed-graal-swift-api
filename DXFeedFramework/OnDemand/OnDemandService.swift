//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

/// Provides on-demand historical tick data replay controls.
/// This class is used to seamlessly transition from ordinary real-time or delayed data feed to the
/// replay of the tick-by-tick history of market data behaviour without any changes to the code
/// that consumes and process these market events.
public class OnDemandService {
    var native: NativeOnDemandService

    private init(native: NativeOnDemandService, endpoint: DXEndpoint?) {
        self.native = native
        self.pEndpoint = endpoint
    }

    /// Returns on-demand service for the default ``DXEndpoint`` instance with
    /// ``DXEndpoint/Role-swift.enum/onDemandFeed``role that is
    /// not connected to any other real-time or delayed data feed.
    ///
    /// it is shortcut for ``getInstance(endpoint:)`` with ``DXEndpoint/getInstance(_:)`` for ``DXEndpoint/Role-swift.enum/onDemandFeed``
    ///  - Returns: ``OnDemandService``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public static func getInstance() throws -> OnDemandService {
        return OnDemandService(native: try NativeOnDemandService.getInstance(), endpoint: nil)
    }

    /// Returns on-demand service for the specified ``DXEndpoint``
    ///  - Returns: ``OnDemandService``
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public static func getInstance(endpoint: DXEndpoint) throws -> OnDemandService {
        return OnDemandService(native: try NativeOnDemandService.getInstance(endpoint: endpoint.nativeEndpoint),
                               endpoint: endpoint)
    }

    private weak var pEndpoint: DXEndpoint?

    private lazy var endpoint: DXEndpoint? = {
        return try? native.getEndpoint()
    }()

    /// Returns ``DXEndpoint`` that is associated with this on-demand service.
    public func getEndpoint() -> DXEndpoint? {
        if let endpoint = pEndpoint {
            return endpoint
        }
        return endpoint
    }

    /// Returns true  when on-demand historical data replay mode is supported.
    public var isReplaySupported: Bool? {
        return native.isReplaySupported
    }

    /// Returns true when this on-demand historical data replay service is in replay mode.
    public var isReplay: Bool? {
        return native.isReplay
    }

    /// Returns true when this on-demand historical data replay service is in clear mode.
    public var isClear: Bool? {
        native.isClear
    }

    /// Returns current or last on-demand historical data replay time.
    public var getTime: Date? {
        native.getTime
    }

    /// Returns on-demand historical data replay speed.
    public var getSpeed: Double? {
        native.getSpeed
    }

    /// Turns on-demand historical data replay mode from a specified time with real-time speed.
    /// - Parameters: time to start replay from.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func replay(date: Date) throws {
        try native.replay(date: date)
    }

    /// Turns on-demand historical data replay mode from a specified time with real-time speed.
    /// - Parameters: 
    ///   - date: time to start replay from.
    ///   - speed: speed to start replay with. Use 1 for real-time speed, < 1 for faster than real-time speed, > 1 for slower than real-time speed, and 0 for pause.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func replay(date: Date, speed: Double) throws {
        try native.replay(date: date, speed: speed)
    }

    /// Pauses on-demand historical data replay and keeps data snapshot.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func pause() throws {
        try native.pause()
    }

    /// Stops on-demand historical data replay and resumes ordinary data feed.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func stopAndResume() throws {
        try native.stopAndResume()
    }

    /// Stops incoming data and clears it without resuming data updates.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func stopAndClear() throws {
        try native.stopAndClear()
    }

    ///  Changes on-demand historical data replay speed while continuing replay at current ``getTime``.
    ///  Speed is measured with respect to the real-time playback speed.
    /// - Parameters:
    ///   - speed: on-demand historical data replay speed.
    /// - Throws: ``GraalException``. Rethrows exception from Java.
    public func setSpeed(_ speed: Double) throws {
        try native.setSpeed(speed)
    }

}

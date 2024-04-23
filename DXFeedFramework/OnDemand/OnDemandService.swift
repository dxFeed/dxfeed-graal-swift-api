//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import Foundation

public class OnDemandService {
    var native: NativeOnDemandService

    private init(native: NativeOnDemandService) {
        self.native = native
    }

    public static func getInstance() throws -> OnDemandService {
        return OnDemandService(native: try NativeOnDemandService.getInstance())
    }

    public static func getInstance(endpoint: DXEndpoint) throws -> OnDemandService {
        return OnDemandService(native: try NativeOnDemandService.getInstance(endpoint: endpoint.nativeEndpoint))
    }

    public lazy var endpoint: DXEndpoint? = {
        return try? native.getEndpoint()
    }()

    public var isReplaySupported: Bool? {
        return native.isReplaySupported
    }

    public var isReplay: Bool? {
        return native.isReplay
    }

    public var isClear: Bool? {
        native.isClear
    }

    public var getTime: Date? {
        native.getTime
    }

    public var getSpeed: Double? {
        native.getSpeed
    }

    public func replay(date: Date) throws {
        try native.replay(date: date)
    }

    public func replay(date: Date, speed: Double) throws {
        try native.replay(date: date, speed: speed)
    }

    public func pause() throws {
        try native.pause()
    }

    public func stopAndResume() throws {
        try native.stopAndResume()
    }

    public func stopAndClear() throws {
        try native.stopAndClear()
    }

    public func setSpeed(_ speed: Double) throws {
        try native.setSpeed(speed)
    }

}

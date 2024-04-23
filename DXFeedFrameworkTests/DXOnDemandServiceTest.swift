//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
import DXFeedFramework

final class DXOnDemandServiceTest: XCTestCase {
    func testCreateService() throws {
        let service = try OnDemandService.getInstance()
        XCTAssertNotNil(service.getEndpoint())
        XCTAssert(service.getEndpoint() === service.getEndpoint())
        checkNullBalues(service: service)
        var endpoint: DXEndpoint? = try DXEndpoint.create(.onDemandFeed)
        let service2 = try OnDemandService.getInstance(endpoint: endpoint!)
        checkNullBalues(service: service2)
        weak var endpoint2 = service2.getEndpoint()
        weak var endpoint3 = service2.getEndpoint()
        XCTAssert(endpoint2 === endpoint3)
        XCTAssert(endpoint === endpoint3)
        endpoint = nil
        XCTAssert(endpoint2 !== service2.getEndpoint())

    }

    private func checkNullBalues(service: OnDemandService) {
        XCTAssertNotEqual(nil, service.isClear)
        XCTAssertNotEqual(nil, service.isReplaySupported)
        XCTAssertNotEqual(nil, service.isReplay)
        XCTAssertNotEqual(nil, service.getTime)
        XCTAssertNotEqual(nil, service.getSpeed)
    }
}

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
        checkNullBalues(service: service)
        let endpoint = try DXEndpoint.create(.onDemandFeed)
        let service2 = try OnDemandService.getInstance(endpoint: endpoint)
        checkNullBalues(service: service2)
        let endpoint2 = service2.endpoint
        let endpoint3 = service2.endpoint
        XCTAssert(endpoint2 === endpoint3)
    }

    private func checkNullBalues(service: OnDemandService) {
        XCTAssertNotEqual(nil, service.isClear)
        XCTAssertNotEqual(nil, service.isReplaySupported)
        XCTAssertNotEqual(nil, service.isReplay)
        XCTAssertNotEqual(nil, service.getTime)
        XCTAssertNotEqual(nil, service.getSpeed)
    }
}

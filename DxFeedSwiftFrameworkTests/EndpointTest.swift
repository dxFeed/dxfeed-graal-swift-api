//
//  EndpointTest.swift
//  DxFeedSwiftFrameworkTests
//
//  Created by Aleksey Kosylo on 21.03.2023.
//

import XCTest
@testable import DxFeedSwiftFramework

final class EndpointTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBuilder() throws {    
        let endpoint = try DXFEndpoint.builder().withRole(.feed).withProperty("test", "value").build()
        
        XCTAssert(endpoint != nil, "Endpoint shouldn't be nil")
    }

}

//
//
//  Copyright (C) 2024 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//  

import XCTest
@testable import DXFeedFramework

final class DXAuthTokenTest: XCTestCase {
    let user = StringUtil.random(length: 15)
    let password = StringUtil.random(length: 15)
    let value = StringUtil.random(length: 15)
    let scheme = StringUtil.random(length: 15)

    func testBasicToken1() throws {
        let token = try DXAuthToken.createBasicToken("\(user):\(password)")
        XCTAssertEqual(user, token.user)
        XCTAssertEqual(password, token.password)
    }

    func testBasicToken2() throws {
        let token: DXAuthToken = try DXAuthToken.createBasicToken(user, password)
        XCTAssertEqual(user, token.user)
        XCTAssertEqual(password, token.password)
    }

    func testBasicToken3() throws {
        let token: DXAuthToken? = try DXAuthToken.createBasicToken("", "")
        XCTAssert(token == nil)
        XCTAssertEqual(nil, token?.user)
        XCTAssertEqual(nil, token?.password)
    }

    func testBearerToken1() throws {
        let token: DXAuthToken = try DXAuthToken.createBearerToken(value)
        XCTAssertEqual(nil, token.user)
        XCTAssertEqual(nil, token.password)
        XCTAssertEqual(value, token.value)
    }

    func testBearerTokenException() throws {
        let expectation = expectation(description: "")
        do {
            let token: DXAuthToken = try DXAuthToken.createBearerToken("")
        } catch {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testBearerToken2() throws {
        let token: DXAuthToken? = try DXAuthToken.createBearerToken(value)
        XCTAssertEqual(nil, token?.user)
        XCTAssertEqual(nil, token?.password)
        XCTAssertEqual(value, token?.value)
    }

    func testCreateCustomToken() throws {
        let token = try DXAuthToken.createCustomToken(scheme, value)
        XCTAssertEqual(nil, token.user)
        XCTAssertEqual(nil, token.password)
        XCTAssertEqual(value, token.value)
        XCTAssertEqual(scheme, token.scheme)
    }
}

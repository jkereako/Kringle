//
//  EndpointTests.swift
//  KringleTests
//
//  Created by Jeff Kereakoglow on 5/11/19.
//  Copyright © 2019 AlexisDigital. All rights reserved.
//

import XCTest
@testable import Kringle

final class EndpointTests: XCTestCase {
    func testBuildPath() {
        let expectation = "/fake/path?arg1=foo&arg2=bar"
        let path = FakeEndpoint.company(companyName: "apple").buildPath(
            "/fake/path",
            appendingQueryItems: [
                URLQueryItem(name: "arg1", value: "foo"),
                URLQueryItem(name: "arg2", value: "bar")
            ]
        )

        XCTAssertEqual(path, expectation)
    }
}

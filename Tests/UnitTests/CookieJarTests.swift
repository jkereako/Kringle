//
//  CookieJarTests.swift
//  KringleTests
//
//  Created by Jeff Kereakoglow on 4/14/19.
//  Copyright © 2019 AlexisDigital. All rights reserved.
//

import XCTest
@testable import Kringle

final class CookieJarTests: XCTestCase {
    private var cookieJar: CookieJar!
    private var endpoint: MockEndpoint!

    override func setUp() {
        endpoint = MockEndpoint.company(companyName: "Apple")
        cookieJar = CookieJar(endpoint: endpoint)

        HTTPCookieStorage.shared.cookies?.forEach {
            HTTPCookieStorage.shared.deleteCookie($0)
        }
    }

    func testSetCookie() {
        // Arrange
        let name = "kit_harrington"
        let value = "Jon Snow"

        // Act
        cookieJar.setCookie(value, forName: name)

        let cookies = HTTPCookieStorage.shared.cookies!

        // Assert
        XCTAssertEqual(1, cookies.count)

        let cookie = cookies.first { $0.name == name }!

        XCTAssertEqual(value, cookie.value)
    }

    func testGetCookie() {
        // Arrange
        let name = "liam_cunningham"
        let value = "The Onion Knight"

        // Act
        setCookie(name: name, value: value)

        let cookieValue = cookieJar.cookie(forName: name)

        // Assert
        XCTAssertEqual(value, cookieValue)
    }

    func testDeleteCookie() {
        // Arrange
        let name = "sophie_turner"
        let value = "Sansa Stark"

        // Act
        setCookie(name: name, value: value)

        // Assert
        XCTAssertEqual(1, HTTPCookieStorage.shared.cookies!.count)
        XCTAssertTrue(cookieJar.deleteCookie(name))
        XCTAssertEqual(0, HTTPCookieStorage.shared.cookies!.count)
    }

    func testDeleteCookieOnlyRemovesTheProvidedCookieName() {
        // Arrange
        let deletedCookieName = "cookie_#3"
        let limit = 10

        for i in 0..<limit {
            setCookie(name: "cookie_#\(i)", value: "\(i)")
        }

        XCTAssertEqual(limit, HTTPCookieStorage.shared.cookies!.count)

        // Act
        XCTAssertTrue(cookieJar.deleteCookie(deletedCookieName))

        // Assert
        XCTAssertEqual(limit - 1, HTTPCookieStorage.shared.cookies!.count)

        HTTPCookieStorage.shared.cookies!.forEach {
            XCTAssertNotEqual(deletedCookieName, $0.name)
        }
    }

    func testClearCookies() {
        // Arrange
        let limit = 10

        for i in 0..<limit {
            setCookie(name: "cookie_#\(i)", value: "\(i)")
        }

        XCTAssertEqual(limit, HTTPCookieStorage.shared.cookies!.count)

        // Act
        cookieJar.clearCookies()

        // Assert
        XCTAssertEqual(0, HTTPCookieStorage.shared.cookies!.count)
    }

    func testClearCookiesIsIdempotentWhenNoCookiesExist() {
        XCTAssertEqual(0, HTTPCookieStorage.shared.cookies!.count)

        // Act
        cookieJar.clearCookies()

        // Assert
        XCTAssertEqual(0, HTTPCookieStorage.shared.cookies!.count)
    }


    func testSetCookiesHeaderStoresCookie() {
        // Arrange
        let name = "tl"
        let value = "tyrion_lanister"
        let urlSession = MockURLSession()
        let networkClient = NetworkClient(urlSession: urlSession)

        urlSession.mockStatusCode = 200
        urlSession.mockHeaders = ["Set-Cookie": "\(name)=\(value); Expires=Sun, 21 Apr 2019 14:22:11"]

        // Act
        networkClient.get(endpoint: endpoint).then { [unowned self] _ in
            let cookie = self.cookieJar.cookie(forName: name)

            // Assert
            XCTAssertEqual(1, HTTPCookieStorage.shared.cookies!.count)
            XCTAssertEqual(value, cookie)

            }.catch { error in
                XCTFail("Unexpected behavior: \(error.localizedDescription)")
        }
    }
    
    func testExpiredSetCookiesHeaderDeletesCookies() {
        // Arrange
        let name = "tl"
        let value = "tyrion_lanister"
        let urlSession = MockURLSession()
        let networkClient = NetworkClient(urlSession: urlSession)
        urlSession.mockStatusCode = 200
        urlSession.mockHeaders = ["Set-Cookie": "\(name); Expires=Mon, 15 Apr 2019 14:22:11"]
        
        setCookie(name: name, value: value)
        
        // Act
        networkClient.get(endpoint: endpoint).then { [unowned self] _ in
            // Assert
            print(HTTPCookieStorage.shared.cookies!)
            XCTAssertEqual(0, HTTPCookieStorage.shared.cookies!.count)
            
            }.catch { error in
                XCTFail("Unexpected behavior: \(error.localizedDescription)")
        }
    }
}

// MARK: - Helpers
private extension CookieJarTests {
    func setCookie(name: String, value: String) {
        let cookieProperties: [HTTPCookiePropertyKey: Any]

        cookieProperties = [.name: name,
                            .value: value,
                            .path: "/",
                            .domain: endpoint.domain]

        let cookie = HTTPCookie(properties: cookieProperties)!

        HTTPCookieStorage.shared.setCookie(cookie)
    }
}

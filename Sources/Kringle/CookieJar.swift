//
//  CookieJar.swift
//  FBLPromises
//
//  Created by Jeff Kereakoglow on 4/14/19.
//  Copyright © 2019 AlexisDigital. All rights reserved.
//

import Foundation

final public class CookieJar {
    private let endpoint: Endpoint

    public init(endpoint: Endpoint) {
        self.endpoint = endpoint
    }

    public func setCookie(_ value: String, forKey key: String) {
        let host = endpoint.baseURL.host!
        let cookieProperties: [HTTPCookiePropertyKey : Any]

        let domain = "." + host.components(separatedBy: ".").dropFirst().joined(separator: ".")
        cookieProperties = [.name: key,
                            .value: value,
                            .path: "/",
                            .domain: domain]

        let cookie = HTTPCookie(properties: cookieProperties)!

        HTTPCookieStorage.shared.setCookie(cookie)
    }

    public func value(forKey key: String) -> String? {
        guard let cookies = HTTPCookieStorage.shared.cookies(for: endpoint.baseURL) else {
            return nil
        }

        let cookie = cookies.first { $0.name == key }

        return cookie?.value ?? nil
    }

    public func clearCookies() -> Bool {
        guard let cookies = HTTPCookieStorage.shared.cookies(for: endpoint.baseURL) else {
            return false
        }

        for cookie in cookies {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }

        return true
    }
}

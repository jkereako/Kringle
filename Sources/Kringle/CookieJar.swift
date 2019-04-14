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

    public func setCookies(with httpURLResponse: HTTPURLResponse) {
        guard let headerFields = httpURLResponse.allHeaderFields as? [String: String] else {
            return
        }

        let cookies = HTTPCookie.cookies(
            withResponseHeaderFields: headerFields, for: endpoint.baseURL
        )

        if cookies.count < 1 {
            return
        }

        HTTPCookieStorage.shared.setCookies(cookies, for: endpoint.baseURL, mainDocumentURL: nil)
    }

    public func setCookie(_ value: String, forName name: String) {
        let host = endpoint.baseURL.host!
        let cookieProperties: [HTTPCookiePropertyKey : Any]
        let domain = "." + host.components(separatedBy: ".").dropFirst().joined(separator: ".")

        cookieProperties = [.name: name,
                            .value: value,
                            .path: "/",
                            .domain: domain]

        let cookie = HTTPCookie(properties: cookieProperties)!

        HTTPCookieStorage.shared.setCookie(cookie)
    }

    public func cookie(forName name: String) -> String? {
        guard let cookies = HTTPCookieStorage.shared.cookies(for: endpoint.baseURL) else {
            return nil
        }

        let cookie = cookies.first { $0.name == name }

        return cookie?.value ?? nil
    }

    public func deleteCookie(_ name: String) -> Bool {
        guard let cookies = HTTPCookieStorage.shared.cookies(for: endpoint.baseURL) else {
            return false
        }

        guard let cookie = cookies.first(where: { $0.name == name }) else {
            return false
        }

        HTTPCookieStorage.shared.deleteCookie(cookie)

        return true
    }

    public func clearCookies() {
        HTTPCookieStorage.shared.cookies(for: endpoint.baseURL)?.forEach {
            HTTPCookieStorage.shared.deleteCookie($0)
        }
    }
}

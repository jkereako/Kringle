//
//  CookieJar.swift
//  Kringle
//
//  Created by Jeff Kereakoglow on 4/14/19.
//  Copyright © 2019 AlexisDigital. All rights reserved.
//

import Foundation

final public class CookieJar: CookieJarType {
    private let endpoint: Endpoint
    
    public init(endpoint: Endpoint) {
        self.endpoint = endpoint
    }

    public func cookieDomain(for endpoint: Endpoint) -> String {
        let host = endpoint.baseURL.host!
        let components = host.components(separatedBy: ".")

        var domainComponents = components

        if components.count >= 2 {
            domainComponents = Array(components.dropFirst(components.count - 2))
        }

        return ".\(domainComponents.joined(separator: "."))"
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
        let cookieProperties: [HTTPCookiePropertyKey : Any]

        cookieProperties = [.name: name,
                            .value: value,
                            .path: "/",
                            .domain: cookieDomain(for: endpoint)]
        
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

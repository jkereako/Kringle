//
//  FakeEndpoint.swift
//  KringleTests
//
//  Created by Jeff Kereakoglow on 4/14/19.
//

import Foundation
@testable import Kringle

enum FakeEndpoint {
    case symbols
    case company(companyName: String)
    case financials(companyName: String)
}

extension FakeEndpoint: Endpoint {
    var baseURL: URL { return URL(string: "https://api.iextrading.com/1.0")! }
    var path: String {
        switch self {
        case .symbols:
            return "/ref-data/symbols"
        case .company(let companyName):
            return "/stock/\(companyName)/company"
        case .financials(let companyName):
            return "/stock/\(companyName)/financials"
        }
    }
}

extension FakeEndpoint {
    var domain: String { return ".iextrading.com" }
}

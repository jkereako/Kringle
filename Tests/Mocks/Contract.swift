//
//  Contract.swift
//  KringleTests
//
//  Created by Jeff Kereakoglow on 4/14/19.
//

import Foundation

struct Contract: Codable {
    let title: String
    let date: Date
    let messages: [String]
}

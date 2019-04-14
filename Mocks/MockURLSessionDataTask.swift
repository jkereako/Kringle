//
//  MockURLSessionDataTask.swift
//  Kringle
//
//  Created by Jeff Kereakoglow on 4/14/19.
//

import Foundation

final class MockURLSessionDataTask: URLSessionDataTask {

    // Although this overridden method seems pointless, it is required to avoid the following
    // exception from being thrown:
    //
    // '-resume cannot be sent to abstract instance of class Kringle.MockURLSessionDataTask'
    //
    // This was a bit confusing because neither Objective-C nor Swift support abstract classes.
    override func resume() {
    }
}

//
//  URLSessionType.swift
//  FBLPromises
//
//  Created by Jeff Kereakoglow on 4/14/19.
//

import Foundation

protocol URLSessionType {
    func task(with request: URLRequest,
              completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}


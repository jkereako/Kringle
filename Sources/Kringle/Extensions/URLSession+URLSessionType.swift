//
//  URLSession+URLSessionType.swift
//  Kringle
//
//  Created by Jeff Kereakoglow on 4/14/19.
//

import Foundation

extension URLSession: URLSessionType {
    func task(with request: URLRequest,
              completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        return dataTask(with: request, completionHandler: completionHandler)
    }
}

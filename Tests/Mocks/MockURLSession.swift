//
//  MockURLSession.swift
//  Kringle
//
//  Created by Jeff Kereakoglow on 4/14/19.
//

import Foundation
@testable import Kringle

final class MockURLSession: URLSessionType {
    var mockData: Data?
    var mockError: Error?
    var mockStatusCode: Int = 200
    var mockHeaders: [String : String]?

    private (set) var httpMethod: String!
    private (set) var url: URL!

    func task(with request: URLRequest,
              completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionDataTask {

            url = request.url!
            httpMethod = request.httpMethod!

            let urlResponse = HTTPURLResponse(
                url: url,
                statusCode: mockStatusCode,
                httpVersion: "2",
                headerFields: mockHeaders
            )
            
            completionHandler(mockData, urlResponse, mockError)
            
            return MockURLSessionDataTask()
    }
}

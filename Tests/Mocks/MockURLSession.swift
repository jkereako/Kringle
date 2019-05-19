//
//  MockURLSession.swift
//  KringleTests
//
//  Created by Jeff Kereakoglow on 4/14/19.
//

import Foundation
@testable import Kringle

final class MockURLSession: URLSession {
    var mockData: Data?
    var mockError: Error?
    var mockStatusCode: Int = 200
    var mockHeaders: [String: String]?

    private (set) var headers: [String: String]!
    private (set) var httpMethod: String!
    private (set) var url: URL!
    private (set) var body: Data!
    
    override var configuration: URLSessionConfiguration {
        return .default
    }
    
    override func dataTask(with request: URLRequest,
                           completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionDataTask {

            headers = request.allHTTPHeaderFields
            httpMethod = request.httpMethod
            url = request.url
            body = request.httpBody
            
            let urlResponse = HTTPURLResponse(
                url: url,
                statusCode: mockStatusCode,
                httpVersion: "2",
                headerFields: mockHeaders
            )
            
            completionHandler(mockData, urlResponse, mockError)
            
            return FakeURLSessionDataTask()
    }
}

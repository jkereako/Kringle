//
//  NetworkClient.swift
//  Kringle
//
//  Created by Jeff Kereakoglow on 4/14/19.
//

import Foundation
import Promises

open class NetworkClient {
    /// Custom headers
    public var headers: [String: String]
    public var defaultQueryParams: [String: String]

    /// Specify the JSON date encoding strategy
    public var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy {
        didSet {
            coder.encoder.dateEncodingStrategy = dateEncodingStrategy
        }
    }
    
    /// Specify the JSON date decoding strategy
    public var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        didSet {
            coder.decoder.dateDecodingStrategy = dateDecodingStrategy
        }
    }
    
    private let coder: Coder
    private let standardHeaders = [
        "Accept": "application/json",
        "Accept-Charset": "UTF-8",
        "Accept-Encoding": "gzip"
    ]
    private let urlSession: URLSession
    
    // Allow for dependency injection to make the class testable
    public init(urlSession: URLSession = URLSession(configuration: .default)) {
        headers = [String: String]()
        defaultQueryParams = [String: String]()
        dateEncodingStrategy = .deferredToDate
        dateDecodingStrategy = .deferredToDate
        self.urlSession = urlSession
        coder = Coder(encoder: JSONEncoder(), decoder: JSONDecoder())
    }

    public func get(_ endpoint: Endpoint, query: [String: String] = [:]) -> Promise<Void> {
        return sendRequestIgnoringResponse(endpoint: endpoint, httpMethod: .get, query: query)
    }
    
    public func get<T: Decodable>(_ endpoint: Endpoint,
                                  decodingResponseTo contract: T.Type,
                                  query: [String: String] = [:]) -> Promise<T> {
        return sendRequestDecodingResponse(
            endpoint: endpoint, httpMethod: .get, decodable: contract, query: query
        )
    }
    
    public func put(_ body: Data, to endpoint: Endpoint) -> Promise<Void> {
        return sendRequestIgnoringResponse(
            endpoint: endpoint, httpMethod: .put, body: body
        )
    }
    
    public func put<T: Decodable>(_ body: Data,
                                  to endpoint: Endpoint,
                                  decodingResponseTo contract: T.Type) -> Promise<T> {
        
        return sendRequestDecodingResponse(
            endpoint: endpoint, httpMethod: .put, decodable: contract, body: body
        )
    }
    
    public func post(_ body: Data, to endpoint: Endpoint) -> Promise<Void> {
        return sendRequestIgnoringResponse(
            endpoint: endpoint, httpMethod: .post, body: body
        )
    }
    
    public func post<T: Decodable>(_ body: Data,
                                   to endpoint: Endpoint,
                                   decodingResponseTo contract: T.Type) -> Promise<T> {
        
        return sendRequestDecodingResponse(
            endpoint: endpoint, httpMethod: .post, decodable: contract, body: body
        )
    }
    
    public func delete(_ endpoint: Endpoint) -> Promise<Void> {
        return sendRequestIgnoringResponse(endpoint: endpoint, httpMethod: .delete)
    }
    
    public func delete<T: Decodable>(_ endpoint: Endpoint,
                                     decodingResponseTo contract: T.Type) -> Promise<T> {
        
        return sendRequestDecodingResponse(
            endpoint: endpoint, httpMethod: .delete, decodable: contract
        )
    }
}

// MARK: - Private helpers
private extension NetworkClient {
    func setHeaders(for request: NSMutableURLRequest) {
        standardHeaders.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
    }
    
    func sendRequestIgnoringResponse(endpoint: Endpoint,
                                     httpMethod: HTTPMethod,
                                     query: [String: String] = [:],
                                     body: Data? = nil) -> Promise<Void> {
        
        let promise = sendRequestToEndpoint(
            endpoint, httpMethod: httpMethod, query: query, body: body
        )
        
        // Implicitly cast `Promise<Data?>` to `Promise<Void>`
        return promise.then { _ -> Void  in return }
    }
    
    func sendRequestDecodingResponse<T: Decodable>(endpoint: Endpoint,
                                                   httpMethod: HTTPMethod,
                                                   decodable: T.Type,
                                                   query: [String: String] = [:],
                                                   body: Data? = nil) -> Promise<T> {
        
        let promise = sendRequestToEndpoint(
            endpoint, httpMethod: httpMethod, query: query, body: body
        )
        
        return promise.then { [unowned self] (data) in
            guard let responseData = data else {
                throw NetworkError.emptyResponse
            }
            
            return self.coder.decode(responseData, to: T.self)
        }
    }
    
    func sendRequestToEndpoint(_ endpoint: Endpoint,
                               httpMethod: HTTPMethod,
                               query: [String: String] = [:],
                               body: Data? = nil) -> Promise<Data?> {
        
        let url = endpoint.baseURL.appendingPathComponent(endpoint.path)
        var urlComponents = URLComponents(string: url.absoluteString)!

        // The Dictionary merge below will replace keys in `query` that match
        // with keys in `defaultQuery`
        //
        // let dictionary = ["a": 1, "b": 2]
        // let newKeyValues = ["a": 3, "b": 4]
        //
        // ["b": 4, "a": 3]
        //
        // see: https://stackoverflow.com/questions/26728477/how-to-combine-two-dictionary-instances-in-swift#43615143
        let mergedQueryParams = defaultQueryParams.merging(query) {
            (_, new) in new
        }

        if mergedQueryParams.count > 0 {
            urlComponents.queryItems = query.map {
                URLQueryItem(name: $0.0, value: $0.1)
            }
        }
        
        let mutableRequest = NSMutableURLRequest(url: urlComponents.url!)
        
        mutableRequest.httpMethod = httpMethod.rawValue
        
        // `httpBody` *must* be the last property that we set because of this bug: https://bugs.swift.org/browse/SR-6687
        mutableRequest.httpBody = body
        
        setHeaders(for: mutableRequest)
        
        return Promise<Data?> { fulfill, reject in
            let request = mutableRequest as URLRequest
            let task = self.urlSession.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    reject(NetworkError.emptyResponse)
                    return
                }
                
                let cookieJar = CookieJar(endpoint: endpoint)
                
                switch httpResponse.statusCode {
                // Success!
                case 200...299:
                    fulfill(data)
                    
                // Redirection
                case 300...399:
                    // Not sure what to do here. I broke out redirection status codes in case we
                    // want to handle these separately in the future.
                    fulfill(data)
                    
                // Client error
                case 400...499:
                    reject(NetworkError.clientError(httpStatusCode: httpResponse.statusCode))
                    
                // Server error
                case 500...599:
                    reject(NetworkError.serverError(httpStatusCode: httpResponse.statusCode))
                    
                default:
                    // This should never happen.
                    assertionFailure("Unexpected response code.")
                    reject(NetworkError.unknown)
                }
                
                // Save cookies for all responses that have the header "Set-Cookie".
                // See https://tools.ietf.org/html/rfc6265#section-4.1
                cookieJar.setCookies(with: httpResponse)
            }
            
            // Start the request
            task.resume()
        }
    }
}

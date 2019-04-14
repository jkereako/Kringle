//
//  NetworkClient.swift
//  Kringle
//
//  Created by Jeff Kereakoglow on 4/14/19.
//

import Foundation
import Promises

public final class NetworkClient: NetworkClientType {
    fileprivate let urlSession: URLSessionType
    fileprivate let headers: [String: String]
    fileprivate let coder: Coder

    // Allow for dependency injection to make the class testable
    init(urlSession: URLSessionType = URLSession(configuration: URLSessionConfiguration.default)) {
        self.urlSession = urlSession
        self.headers = [:]
        self.coder = Coder()
    }

    public func get(endpoint: Endpoint) -> Promise<Void> {
        let promise = sendRequestIgnoringResponse(endpoint: endpoint, httpMethod: .get)

        return promise.then { _ -> Void  in
            return
        }
    }

    public func get<T: Decodable>(endpoint: Endpoint, contract: T.Type) -> Promise<T> {
        let promise = sendRequestDecodingResponse(
            endpoint: endpoint, httpMethod: .get, decodable: contract
        )

        return promise.then { _ -> Void  in
            return
        }
    }

    public func put(endpoint: Endpoint, body: Data) -> Promise<Void> {
        let promise = sendRequestIgnoringResponse(endpoint: endpoint, httpMethod: .put, body: body)

        return promise.then { _ -> Void  in
            return
        }
    }

    public func put<T: Decodable>(endpoint: Endpoint, body: Data, contract: T.Type) -> Promise<T> {
        let promise = sendRequestDecodingResponse(
            endpoint: endpoint, httpMethod: .put, decodable: contract, body: body
        )

        return promise.then { _ -> Void  in
            return
        }
    }

    public func post(endpoint: Endpoint, body: Data) -> Promise<Void> {
        let promise = sendRequestIgnoringResponse(endpoint: endpoint, httpMethod: .post, body: body)

        return promise.then { _ -> Void  in
            return
        }
    }

    public func post<T: Decodable>(endpoint: Endpoint, body: Data, contract: T.Type) -> Promise<T> {
        let promise = sendRequestDecodingResponse(
            endpoint: endpoint, httpMethod: .post, decodable: contract, body: body
        )

        return promise.then { _ -> Void  in
            return
        }
    }

    public func delete(endpoint: Endpoint) -> Promise<Void> {
        let promise = sendRequestIgnoringResponse(endpoint: endpoint, httpMethod: .delete)

        return promise.then { _ -> Void  in
            return
        }
    }

    public func delete<T: Decodable>(endpoint: Endpoint, contract: T.Type) -> Promise<T> {
        let promise = sendRequestDecodingResponse(
            endpoint: endpoint, httpMethod: .delete, decodable: contract
        )

        return promise.then { _ -> Void  in
            return
        }
    }
}

// MARK: - Private helpers
private extension NetworkClient {
    func sendRequestIgnoringResponse(endpoint: Endpoint, httpMethod: HTTPMethod, body: Data? = nil) -> Promise<Void> {
        // Implicitly cast `Promise<Data?>` to `Promise<Void>`
        return sendRequestToEndpoint(endpoint, httpMethod: httpMethod, body: body).then { _ -> Void  in
            return
        }
    }

    func sendRequestDecodingResponse<T: Decodable>(endpoint: Endpoint,
                                                   httpMethod: HTTPMethod,
                                                   decodable: T.Type,
                                                   body: Data? = nil) -> Promise<T> {
        return sendRequestToEndpoint(endpoint, httpMethod: httpMethod, body: body).then { [unowned self] (data) in
            guard let responseData = data else {
                throw NetworkError.emptyResponse
            }

            return self.coder.decode(responseData, to: T.self)
        }
    }

    func sendRequestToEndpoint(_ endpoint: Endpoint, httpMethod: HTTPMethod, body: Data? = nil) -> Promise<Data?> {
        let url = endpoint.baseURL.appendingPathComponent(endpoint.path)
        let request = NSMutableURLRequest(url: url)

        request.httpMethod = httpMethod.rawValue
        request.httpBody = body
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        return Promise<Data?> { fulfill, reject in
            let task = self.urlSession.task(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in

                guard let httpResponse = response as? HTTPURLResponse else {
                    reject(NetworkError.emptyResponse)
                    return
                }

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
            }

            // Start the request
            task.resume()
        }
    }
}
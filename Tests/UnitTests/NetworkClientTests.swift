//
//  NetworkClientTests.swift
//  KringleTests
//
//  Created by Jeff Kereakoglow on 4/14/19.
//

import XCTest
@testable import Kringle

final class NetworkClientTests: XCTestCase {
    private var networkClient: NetworkClientType!
    private var urlSession: MockURLSession!
    private var coder: Coder!
    private var endpoint: MockEndpoint!

    override func setUp() {
        urlSession = MockURLSession()
        coder = Coder()
        endpoint = MockEndpoint.company(companyName: "AAPL")
    }

    override func tearDown() {
        networkClient = nil
    }

    func testSuccessfulGetRequest() {
        // Arrange
        urlSession.mockStatusCode = 200
        networkClient = NetworkClient(urlSession: urlSession)

        // Act
        networkClient.get(endpoint: endpoint).then { [unowned self] _ in
            // Assert
            self.helpAssertUrlRequest(endpoint: self.endpoint, httpMethod: .get)
            }.catch { error in
                XCTFail("Unexpected behavior: \(error.localizedDescription)")
        }
    }

    func testSuccessfulGetRequestWithResponse() {
        // Arrange
        let contract = MockContract(
            title: "Apple", messages: ["hi", "lo", "open", "close"]
        )

        coder.encode(contract).then { [unowned self] data in
            self.urlSession.mockData = data
            self.urlSession.mockStatusCode = 200
            self.networkClient = NetworkClient(urlSession: self.urlSession)
            
            // Act
            self.networkClient.get(endpoint: self.endpoint, contract: MockContract.self).then { [unowned self] result in
                // Assert
                self.helpAssertUrlRequest(endpoint: self.endpoint, httpMethod: .get)

                XCTAssertEqual(contract.title, result.title)
                XCTAssertEqual(contract.messages, result.messages)
            }
        }
    }

    func testUnsuccessfulGetRequest() {
        // Arrange
        urlSession.mockStatusCode = 422
        networkClient = NetworkClient(urlSession: urlSession)

        // Act
        networkClient.get(endpoint: endpoint).then {_ in
            // Assert
            XCTFail("Unexpected behavior")
            }.catch { [unowned self] error in
                self.helpAssertUrlRequest(endpoint: self.endpoint, httpMethod: .get)

                XCTAssertTrue(error is NetworkError)
        }
    }

    func testSuccessfulPutRequest() {
        // Arrange
        let body = "Treats of the place Where Oliver Twist was born".data(using: .utf8)!
        urlSession.mockStatusCode = 200
        networkClient = NetworkClient(urlSession: urlSession)

        // Act
        networkClient.put(endpoint: endpoint, body: body).then { [unowned self] _ in
            // Assert
            self.helpAssertUrlRequest(endpoint: self.endpoint, httpMethod: .put)
            }.catch { error in
                XCTFail("Unexpected behavior: \(error.localizedDescription)")
        }
    }

    func helpAssertUrlRequest(endpoint: Endpoint, httpMethod: HTTPMethod, body: Data? = nil) {
        XCTAssertTrue(urlSession.url.absoluteString.contains(endpoint.baseURL.absoluteString))
        XCTAssertTrue(urlSession.url.absoluteString.contains(endpoint.path))
        XCTAssertEqual(httpMethod.rawValue, self.urlSession.httpMethod)

        if let aBody = body {
            XCTAssertEqual(aBody, urlSession.body)
        }
    }
}

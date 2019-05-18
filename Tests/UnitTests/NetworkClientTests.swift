//
//  NetworkClientTests.swift
//  KringleTests
//
//  Created by Jeff Kereakoglow on 4/14/19.
//

import XCTest
@testable import Kringle
@testable import Promises

final class NetworkClientTests: XCTestCase {
    private var networkClient: NetworkClientType!
    private var urlSession: MockURLSession!
    private var coder: Coder!
    private var endpoint: FakeEndpoint!

    override func setUp() {
        urlSession = MockURLSession()
        coder = Coder()
        endpoint = FakeEndpoint.company(companyName: "AAPL")
    }

    override func tearDown() {
        networkClient = nil
    }

    func testSuccessfulGetRequest() {
        // Arrange
        urlSession.mockStatusCode = 200
        networkClient = NetworkClient(urlSession: urlSession)

        // Act
        let promise = networkClient.get(endpoint)

        // Assert
        XCTAssert(waitForPromises(timeout: 1))
        assertUrlRequest(endpoint: self.endpoint, httpMethod: .get)
        XCTAssertNil(promise.error)
    }

    func testSuccessfulGetRequestWithResponse() {
        // Arrange
        let contract = Contract(
            title: "Apple", messages: ["hi", "lo", "open", "close"]
        )

        // Act
        let coderPromise = coder.encode(contract)

        // Assert
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertNotNil(coderPromise.value)
        XCTAssertNil(coderPromise.error)

        // Arrange
        self.urlSession.mockData = coderPromise.value!
        self.urlSession.mockStatusCode = 200
        self.networkClient = NetworkClient(urlSession: self.urlSession)

        // Act
        let networkPromise = networkClient.get(self.endpoint, decodingResponseTo: Contract.self)

        // Assert
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertNotNil(networkPromise.value)
        XCTAssertNil(networkPromise.error)
        XCTAssertEqual(contract.title, networkPromise.value!.title)
        XCTAssertEqual(contract.messages, networkPromise.value!.messages)

        assertUrlRequest(endpoint: self.endpoint, httpMethod: .get)
    }

    func testUnsuccessfulGetRequest() {
        // Arrange
        urlSession.mockStatusCode = 422
        networkClient = NetworkClient(urlSession: urlSession)

        // Act
        let promise = networkClient.get(endpoint)

        // Assert
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertNotNil(promise.error)
        XCTAssertNil(promise.value)
        XCTAssertTrue(promise.error! is NetworkError)
        assertUrlRequest(endpoint: self.endpoint, httpMethod: .get)
    }

    func testSuccessfulPutRequest() {
        // Arrange
        let body = "Treats of the place Where Oliver Twist was born".data(using: .utf8)!
        
        urlSession.mockStatusCode = 200
        networkClient = NetworkClient(urlSession: urlSession)

        // Act
        let promise = networkClient.put(body, to: endpoint)

        // Assert
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertNil(promise.error)
        assertUrlRequest(endpoint: self.endpoint, httpMethod: .put, body: body)
    }

    func testSuccessfulPutRequestWithResponse() {
        // Arrange
        let contract = Contract(
            title: "Apple", messages: ["hi", "lo", "open", "close"]
        )
        let body = "Treats of the place Where Oliver Twist was born".data(using: .utf8)!
        let coderPromise = coder.encode(contract)

        // Assert
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertNil(coderPromise.error)

        // Arrange
        urlSession.mockData = coderPromise.value!
        urlSession.mockStatusCode = 200
        networkClient = NetworkClient(urlSession: self.urlSession)

        // Act
        let networkPromise = networkClient.put(
            body, to: self.endpoint, decodingResponseTo: Contract.self
        )

        // Assert
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertNotNil(networkPromise.value)
        XCTAssertNil(networkPromise.error)
        XCTAssertEqual(contract.title, networkPromise.value!.title)
        XCTAssertEqual(contract.messages, networkPromise.value!.messages)
        assertUrlRequest(endpoint: self.endpoint, httpMethod: .put, body: body)
    }
}

// MARK: - Helpers
private extension NetworkClientTests {
    func assertUrlRequest(endpoint: Endpoint, httpMethod: HTTPMethod, body: Data? = nil) {
        XCTAssertTrue(urlSession.url.absoluteString.contains(endpoint.baseURL.absoluteString))
        XCTAssertTrue(urlSession.url.absoluteString.contains(endpoint.path))
        XCTAssertEqual(httpMethod.rawValue, self.urlSession.httpMethod)

        if let aBody = body {
            XCTAssertEqual(aBody, urlSession.body)
        }
    }
}

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
    private var networkClient: NetworkClient!
    private var urlSession: MockURLSession!
    private var coder: Coder!
    private var endpoint: FakeEndpoint!
    
    override func setUp() {
        urlSession = MockURLSession()
        
        coder = Coder(encoder: JSONEncoder(), decoder: JSONDecoder())
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
        assertURLRequest(endpoint: self.endpoint, httpMethod: .get)
        XCTAssertNil(promise.error)
    }
    
    func testSuccessfulGetRequestWithQuery() {
        // Arrange
        urlSession.mockStatusCode = 200
        networkClient = NetworkClient(urlSession: urlSession)
        let query = ["Fraser": "Crane", "Eddie": "Crane"]
        
        // Act
        let promise = networkClient.get(endpoint, query: query)
        
        // Assert
        XCTAssert(waitForPromises(timeout: 1))
        assertURLRequest(endpoint: self.endpoint, httpMethod: .get)
        XCTAssertNil(promise.error)
        
        query.forEach { (key, value) in
            XCTAssertTrue(urlSession.url.absoluteString.contains(key))
            XCTAssertTrue(urlSession.url.absoluteString.contains(value))
        }
    }
    
    func testSuccessfulGetRequestWithResponse() {
        // Arrange
        let contract = Contract(
            title: "Apple", date: Date(), messages: ["hi", "lo", "open", "close"]
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
        
        assertURLRequest(endpoint: self.endpoint, httpMethod: .get)
    }
    
    func testSuccessfulGetRequestWithCustomDateDecodingStrategy() {
        // Arrange
        var components = DateComponents()
        components.year = 1776
        components.month = 7
        components.day = 2
        components.hour = 15
        components.minute = 16
        components.second = 17
        
        let title = "UNIX Epoch"
        let date = Calendar.current.date(from: components)!
        let response: [String : Any] = [
            "title": title, "date": date.timeIntervalSince1970, "messages": ["test"]
        ]
        
        self.urlSession.mockData = try! JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
        self.urlSession.mockStatusCode = 200
        self.networkClient = NetworkClient(urlSession: self.urlSession)
        self.networkClient.dateDecodingStrategy = .secondsSince1970
        
        // Act
        let networkPromise = networkClient.get(self.endpoint, decodingResponseTo: Contract.self)
        
        // Assert
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertNotNil(networkPromise.value)
        XCTAssertNil(networkPromise.error)
        XCTAssertEqual(title, networkPromise.value!.title)
        XCTAssertEqual(date, networkPromise.value!.date)
        
        assertURLRequest(endpoint: self.endpoint, httpMethod: .get)
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
        assertURLRequest(endpoint: self.endpoint, httpMethod: .get)
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
        assertURLRequest(endpoint: self.endpoint, httpMethod: .put, body: body)
    }
    
    func testSuccessfulPutRequestWithResponse() {
        // Arrange
        let contract = Contract(
            title: "Apple", date: Date(), messages: ["hi", "lo", "open", "close"]
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
        assertURLRequest(endpoint: self.endpoint, httpMethod: .put, body: body)
    }
    
    func testHeadersArePresentInRequest() {
        // Arrange
        let headerKey1 = "foo"
        let headerKey2 = "bar"
        let headers = [headerKey1: "baz", headerKey2: "boom"]
        networkClient = NetworkClient(urlSession: urlSession)
        networkClient.headers = headers
        
        // Act
        let promise = networkClient.get(endpoint)
        
        // Assert
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertNil(promise.error)
        XCTAssertNotNil(promise.value)
        XCTAssertNotNil(urlSession.headers.index(forKey: headerKey1))
        XCTAssertNotNil(urlSession.headers.index(forKey: headerKey2))
    }
}

// MARK: - Helpers
private extension NetworkClientTests {
    func assertURLRequest(endpoint: Endpoint, httpMethod: HTTPMethod, body: Data? = nil) {
        XCTAssertTrue(urlSession.url.absoluteString.contains(endpoint.baseURL.absoluteString))
        XCTAssertTrue(urlSession.url.absoluteString.contains(endpoint.path))
        XCTAssertEqual(httpMethod.rawValue, self.urlSession.httpMethod)
        
        if let aBody = body {
            XCTAssertEqual(aBody, urlSession.body)
        }
    }
}

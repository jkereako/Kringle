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

    override func setUp() {
        urlSession = MockURLSession()
        coder = Coder()
    }

    override func tearDown() {
        networkClient = nil
    }

    func testSuccessfulGetRequest() {
        // Arrange
        let apple = MockEndpoint.company(companyName: "AAPL")
        urlSession.mockStatusCode = 200
        networkClient = NetworkClient(urlSession: urlSession)

        // Act
        networkClient.get(endpoint: apple).then { [unowned self] _ in
            // Assert
            self.helpAssertUrlRequest(endpoint: apple, httpMethod: .get)
            }.catch { error in
                XCTFail("Unexpected behavior: \(error.localizedDescription)")
        }
    }

    func testSuccessfulGetRequestWithResponse() {
        // Arrange
        let contract = MockContract(
            title: "Apple", messages: ["hi", "lo", "open", "close"]
        )
        let apple = MockEndpoint.company(companyName: "AAPL")

        coder.encode(contract).then { [unowned self] data in
            self.urlSession.mockData = data
            self.urlSession.mockStatusCode = 200
            self.networkClient = NetworkClient(urlSession: self.urlSession)
            
            // Act
            self.networkClient.get(endpoint: apple, contract: MockContract.self).then { result in
                // Assert
                self.helpAssertUrlRequest(endpoint: apple, httpMethod: .get)

                XCTAssertEqual(contract.title, result.title)
                XCTAssertEqual(contract.messages, result.messages)
            }
        }
    }

    func testUnsuccessfulGetRequest() {
        // Arrange
        let apple = MockEndpoint.company(companyName: "AAPL")
        urlSession.mockStatusCode = 422
        networkClient = NetworkClient(urlSession: urlSession)

        // Act
        networkClient.get(endpoint: apple).then {_ in
            // Assert
            XCTFail("Unexpected behavior")
            }.catch { error in
                self.helpAssertUrlRequest(endpoint: apple, httpMethod: .get)
                
                XCTAssertTrue(error is NetworkError)
        }
    }

    func helpAssertUrlRequest(endpoint: Endpoint, httpMethod: HTTPMethod) {
        XCTAssertTrue(self.urlSession.url.absoluteString.contains(endpoint.baseURL.absoluteString))
        XCTAssertTrue(self.urlSession.url.absoluteString.contains(endpoint.path))
        XCTAssertEqual(httpMethod.rawValue, self.urlSession.httpMethod)
    }
}

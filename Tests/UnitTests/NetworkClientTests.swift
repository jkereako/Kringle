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
        networkClient.get(endpoint: apple).then {_ in
            XCTAssertTrue(true)
            }.catch { error in XCTFail("Unexpected behavior: \(error.localizedDescription)") }
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
                XCTAssertEqual(contract.title, result.title)
                XCTAssertEqual(contract.messages, result.messages)
            }
        }

    }
}

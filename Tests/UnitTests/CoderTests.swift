//
//  CoderTests.swift
//  KringleTests
//
//  Created by Jeff Kereakoglow on 4/14/19.
//

import XCTest
@testable import Kringle
@testable import Promises

final class CoderTests: XCTestCase {
    private var coder: Coder!

    override func setUp() {
        super.setUp()

        coder = Coder()
    }

    func testDecoderFulfillsPromiseWhenDecodingValidJSON() {
        // Arrange
        let json = "{\"title\":\"success\",\"messages\":[\"Ibizan\",\"afghan\",\"basset\",\"blood\",\"english\",\"walker\"]}"
        let jsonData = json.data(using: .utf8)!

        // Act
        let promise = coder.decode(jsonData, to: Contract.self)

        // Assert
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertNil(promise.error)
        XCTAssertEqual(6, promise.value!.messages.count)
        XCTAssertEqual(promise.value!.title, "success")
    }

    func testDecoderRejectsPromiseWhenDecodingInvalidJSON() {
        // Arrange
        let json = "{not_valid_json(@*"
        let jsonData = json.data(using: .utf8)!

        // Act
        let promise = coder.decode(jsonData, to: Contract.self)

        // Assert
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertNil(promise.value)
        XCTAssertNotNil(promise.error)
    }

    func testEncoderFulfillsPromise() {
        // Arrange
        let pawn = "pawn"
        let rook = "rook"
        let knight = "knight"
        let king = "king"
        let contract = Contract(title: pawn, messages: [rook, knight, king])

        // Act
        let promise = coder.encode(contract)

        // Assert
        XCTAssert(waitForPromises(timeout: 1))
        XCTAssertNil(promise.error)

        let json = String(data: promise.value!, encoding: .utf8)!

        XCTAssertTrue(json.contains("title"))
        XCTAssertTrue(json.contains("messages"))
        XCTAssertTrue(json.contains(pawn))
        XCTAssertTrue(json.contains(rook))
        XCTAssertTrue(json.contains(knight))
        XCTAssertTrue(json.contains(king))
    }
}

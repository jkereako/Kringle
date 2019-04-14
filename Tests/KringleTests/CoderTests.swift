//
//  CoderTests.swift
//  Kringle
//
//  Created by Jeff Kereakoglow on 4/14/19.
//

import XCTest
@testable import Kringle

final class CoderTests: XCTestCase {
    private var coder: CoderType!

    override func setUp() {
        super.setUp()

        coder = Coder()
    }

    func testDecoding() {
        let json = "{\"title\":\"success\",\"messages\":[\"Ibizan\",\"afghan\",\"basset\",\"blood\",\"english\",\"walker\"]}"
        let jsonData = json.data(using: .utf8)!

        _ = coder.decode(jsonData, to: MockContract.self).then { contract in
            XCTAssertEqual(6, contract.messages.count)
            XCTAssertEqual(contract.title, "success")
        }
    }

    func testEncoding() {
        // Arrange
        let pawn = "pawn"
        let rook = "rook"
        let knight = "knight"
        let king = "king"
        let contract = MockContract(title: pawn, messages: [rook, knight, king])

        // Act
        _ = coder.encode(contract).then { data in
            let json = String(data: data, encoding: .utf8)!

            // Assert
            XCTAssertTrue(json.contains("title"))
            XCTAssertTrue(json.contains("messages"))
            XCTAssertTrue(json.contains(pawn))
            XCTAssertTrue(json.contains(rook))
            XCTAssertTrue(json.contains(knight))
            XCTAssertTrue(json.contains(king))
        }
    }
}

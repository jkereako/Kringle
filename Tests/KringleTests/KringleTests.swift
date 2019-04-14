import XCTest
@testable import Kringle

final class KringleTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Kringle().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

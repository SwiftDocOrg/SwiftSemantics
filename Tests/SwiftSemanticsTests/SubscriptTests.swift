@testable import SwiftSemantics
import SwiftSyntax
import XCTest

final class SubscriptTests: XCTestCase {
    func testSubscriptDeclaration() throws {
        let source = #"""
        subscript(index: Int) -> Int?
        """#

        let declarations = try SyntaxParser.declarations(of: Subscript.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertNil(declaration.context)
        XCTAssertEqual(declaration.indices.count, 1)
        XCTAssertEqual(declaration.indices[0].firstName, "index")
        XCTAssertEqual(declaration.indices[0].type, "Int")
        XCTAssertEqual(declaration.returnType, "Int?")
        XCTAssertEqual(declaration.description, source)
    }

    static var allTests = [
        ("testSubscriptDeclaration", testSubscriptDeclaration),
    ]
}


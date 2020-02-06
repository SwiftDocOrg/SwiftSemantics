@testable import SwiftSemantics
import SwiftSyntax
import XCTest

final class OperatorTests: XCTestCase {
    func testSimpleOperatorDeclaration() throws {
        let source = #"""
        prefix operator +++
        """#

        let declarations = try SyntaxParser.declarations(of: Operator.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertEqual(declaration.modifiers.count, 1)
        XCTAssertEqual(declaration.modifiers.first?.name, "prefix")
        XCTAssertEqual(declaration.kind, .prefix)
        XCTAssertEqual(declaration.name, "+++")
//        XCTAssertEqual(declaration.description, source)
    }

    static var allTests = [
        ("testSimpleOperatorDeclaration", testSimpleOperatorDeclaration),
    ]
}


@testable import SwiftSemantics
import SwiftSyntax
import XCTest

final class StructureTests: XCTestCase {
    func testNestedStructureDeclarations() throws {
        let source = #"""
        struct A { struct B { struct C {} } }
        """#

        let declarations = try SyntaxParser.declarations(of: Structure.self, source: source)
        XCTAssertEqual(declarations.count, 3)

        XCTAssertEqual(declarations[0].name, "A")
        XCTAssertEqual(declarations[1].name, "B")
        XCTAssertEqual(declarations[2].name, "C")
    }

    static var allTests = [
        ("testNestedStructureDeclarations", testNestedStructureDeclarations),
    ]
}


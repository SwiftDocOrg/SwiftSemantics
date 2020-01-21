@testable import SwiftSemantics
import SwiftSyntax
import XCTest

final class ModifierTests: XCTestCase {
    func testModifiersForPropertyDeclaration() throws {
        let source = #"""
        public private(set) var title: String
        """#

        let declarations = try SyntaxParser.declarations(of: Variable.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let property = declarations.first!
        XCTAssertEqual(property.modifiers.count, 2)

        XCTAssertEqual(property.modifiers[0].name, "public")
        XCTAssertNil(property.modifiers[0].detail)

        XCTAssertEqual(property.modifiers[1].name, "private")
        XCTAssertEqual(property.modifiers[1].detail, "set")
    }

    static var allTests = [
        ("testModifiersForPropertyDeclaration", testModifiersForPropertyDeclaration),
    ]
}


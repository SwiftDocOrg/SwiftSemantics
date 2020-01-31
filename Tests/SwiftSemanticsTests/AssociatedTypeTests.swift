@testable import SwiftSemantics
import SwiftSyntax
import XCTest

final class AssociatedTypeTests: XCTestCase {
    func testAssociatedTypeDeclaration() throws {
        let source = #"""
        protocol P {
            associatedtype T
        }
        """#

        let declarations = try SyntaxParser.declarations(of: AssociatedType.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let associatedType = declarations.first!

        XCTAssertEqual(associatedType.context, "P")
        XCTAssertEqual(associatedType.attributes.count, 0)
        XCTAssertEqual(associatedType.name, "T")
        XCTAssertEqual(associatedType.description, "associatedtype T")
    }

    static var allTests = [
        ("testAssociatedTypeDeclaration", testAssociatedTypeDeclaration),
    ]
}


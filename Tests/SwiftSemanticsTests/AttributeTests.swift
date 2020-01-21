@testable import SwiftSemantics
import SwiftSyntax
import XCTest

final class AttributeTests: XCTestCase {
    func testPropertyWrapperAttribute() throws {
        let source = #"""
        @propertyWrapper
        struct Atomic {}
        """#

        let declarations = try SyntaxParser.declarations(of: Structure.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let structure = declarations.first!
        XCTAssertEqual(structure.attributes.count, 1)
        let attribute = structure.attributes.first!

        XCTAssertEqual(attribute.name, "propertyWrapper")
        XCTAssert(attribute.arguments.isEmpty)
        XCTAssertEqual(attribute.description, "@propertyWrapper")
    }

    func testAvailableAttribute() throws {
        let source = #"""
        @available(*, unavailable, renamed: "New")
        class Old {}
        """#

        let declarations = try SyntaxParser.declarations(of: Class.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let `class` = declarations.first!
        XCTAssertEqual(`class`.attributes.count, 1)
        let attribute = `class`.attributes.first!

        XCTAssertEqual(attribute.name, "available")
        XCTAssertEqual(attribute.arguments.count, 3)

        XCTAssertNil(attribute.arguments[0].name)
        XCTAssertEqual(attribute.arguments[0].value, "*")

        XCTAssertNil(attribute.arguments[1].name)
        XCTAssertEqual(attribute.arguments[1].value, "unavailable")

        XCTAssertEqual(attribute.arguments[2].name, "renamed")
        XCTAssertEqual(attribute.arguments[2].value, #""New""#)

        XCTAssertEqual(attribute.description, #"@available(*, unavailable, renamed: "New")"#)
    }

    static var allTests = [
        ("testPropertyWrapperAttribute", testPropertyWrapperAttribute),
        ("testAvailableAttribute", testAvailableAttribute),
    ]
}


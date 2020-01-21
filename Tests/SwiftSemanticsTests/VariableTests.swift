@testable import SwiftSemantics
import SwiftSyntax
import XCTest

final class VariableTests: XCTestCase {
    func testVariableDeclarationWithTypeAnnotation() throws {
        let source = #"""
        let greeting: String = "Hello"
        """#

        let declarations = try SyntaxParser.declarations(of: Variable.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertNil(declaration.context)
        XCTAssertEqual(declaration.typeAnnotation, "String")
        XCTAssertEqual(declaration.initializedValue, "\"Hello\"")
        XCTAssertEqual(declaration.description, source)
    }

    func testVariableDeclarationWithoutTypeAnnotation() throws {
        let source = #"""
        let greeting = "Hello"
        """#

        let declarations = try SyntaxParser.declarations(of: Variable.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertNil(declaration.context)
        XCTAssertNil(declaration.typeAnnotation)
        XCTAssertEqual(declaration.initializedValue, "\"Hello\"")
        XCTAssertEqual(declaration.description, source)
    }

    func testTupleVariableDeclaration() throws {
        let source = #"""
        let (greeting, addressee): (String, Thing) = ("Hello", .world)
        """#

              let declarations = try SyntaxParser.declarations(of: Variable.self, source: source)
          XCTAssertEqual(declarations.count, 1)
          let declaration = declarations.first!

          XCTAssert(declaration.attributes.isEmpty)
          XCTAssertNil(declaration.context)
          XCTAssertEqual(declaration.typeAnnotation, "(String, Thing)")
          XCTAssertEqual(declaration.initializedValue, "(\"Hello\", .world)")
          XCTAssertEqual(declaration.description, source)
    }

    func testMultipleVariableDeclaration() throws {
        let source = #"""
        let greeting: String = "Hello", addressee: Thing = .world
        """#

        let declarations = try SyntaxParser.declarations(of: Variable.self, source: source)

        XCTAssertEqual(declarations.count, 2)

        let first = declarations.first!
        XCTAssert(first.attributes.isEmpty)
        XCTAssertNil(first.context)
        XCTAssertEqual(first.typeAnnotation, "String")
        XCTAssertEqual(first.initializedValue, "\"Hello\"")

        let last = declarations.last!
        XCTAssert(last.attributes.isEmpty)
        XCTAssertNil(last.context)
        XCTAssertEqual(last.typeAnnotation, "Thing")
        XCTAssertEqual(last.initializedValue, ".world")
    }

    static var allTests = [
        ("testVariableDeclarationWithTypeAnnotation", testVariableDeclarationWithTypeAnnotation),
        ("testVariableDeclarationWithoutTypeAnnotation", testVariableDeclarationWithoutTypeAnnotation),
        ("testTupleVariableDeclaration", testTupleVariableDeclaration),
        ("testMultipleVariableDeclaration", testMultipleVariableDeclaration),
    ]
}


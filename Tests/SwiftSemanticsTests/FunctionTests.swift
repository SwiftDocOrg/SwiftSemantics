@testable import SwiftSemantics
import SwiftSyntax
import XCTest

final class FunctionTests: XCTestCase {
    func testComplexFunctionDeclaration() throws {
        let source = #"""
        public func dump<T, TargetStream>(_ value: T, to target: inout TargetStream, name: String? = nil, indent: Int = 0, maxDepth: Int = .max, maxItems: Int = .max) -> T where TargetStream: TextOutputStream
        """#
        
        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertEqual(declaration.identifier, "dump")
        XCTAssertEqual(declaration.description, source)
    }

    func testOperatorFunctionDeclarations() throws {
        let source = #"""
        prefix func ¬(value: Bool) -> Bool { !value }
        func ±(lhs: Int, rhs: Int) -> (Int, Int) { (lhs + rhs, lhs - rhs) }
        postfix func °(value: Double) -> String { "\(value)°)" }
        extension Int {
            static func ∓(lhs: Int, rhs: Int) -> (Int, Int) { (lhs - rhs, lhs + rhs) }
        }
        func sayHello() { print("Hello") }
        """#

        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)

        XCTAssertEqual(declarations.count, 5)

        let prefix = declarations[0]
        XCTAssertEqual(prefix.modifiers.map { $0.description}, ["prefix"])
        XCTAssertEqual(prefix.identifier, "¬")
        XCTAssertTrue(prefix.isOperator)

        let infix = declarations[1]
        XCTAssert(infix.modifiers.isEmpty)
        XCTAssertEqual(infix.identifier, "±")
        XCTAssertTrue(infix.isOperator)

        let postfix = declarations[2]
        XCTAssertEqual(postfix.modifiers.map { $0.description}, ["postfix"])
        XCTAssertEqual(postfix.identifier, "°")
        XCTAssertTrue(postfix.isOperator)

        let staticInfix = declarations[3]
        XCTAssertEqual(staticInfix.modifiers.map { $0.description}, ["static"])
        XCTAssertEqual(staticInfix.identifier, "∓")
        XCTAssertTrue(staticInfix.isOperator)

        let nonoperator = declarations[4]
        XCTAssert(nonoperator.modifiers.isEmpty)
        XCTAssertEqual(nonoperator.identifier, "sayHello")
        XCTAssertFalse(nonoperator.isOperator)
    }

    static var allTests = [
        ("testComplexFunctionDeclaration", testComplexFunctionDeclaration),
        ("testOperatorFunctionDeclarations", testOperatorFunctionDeclarations),
    ]
}


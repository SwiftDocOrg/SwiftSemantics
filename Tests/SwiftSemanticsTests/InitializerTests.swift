@testable import SwiftSemantics
import SwiftSyntax
import XCTest

final class InitializerTests: XCTestCase {
    func testInitializerDeclaration() throws {
        let source = #"""
        public class Person {
            public init?(names: String...) throws
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Initializer.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let initializer = declarations.first!

        XCTAssert(initializer.attributes.isEmpty)
        XCTAssertEqual(initializer.keyword, "init")
        XCTAssertEqual(initializer.parameters.count, 1)
        XCTAssertEqual(initializer.parameters[0].firstName, "names")
        XCTAssertNil(initializer.parameters[0].secondName)
        XCTAssertEqual(initializer.parameters[0].type, "String")
        XCTAssertTrue(initializer.parameters[0].variadic)
        XCTAssertEqual(initializer.throwsOrRethrowsKeyword, "throws")
    }

    static var allTests = [
        ("testInitializerDeclaration", testInitializerDeclaration),
    ]
}


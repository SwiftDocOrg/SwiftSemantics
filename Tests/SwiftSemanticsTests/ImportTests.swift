@testable import SwiftSemantics
import SwiftSyntax
import XCTest

final class ImportTests: XCTestCase {
    func testSimpleImportDeclaration() throws {
        let source = #"""
        import Foundation
        """#

        let declarations = try SyntaxParser.declarations(of: Import.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertNil(declaration.kind)
        XCTAssertEqual(declaration.pathComponents, ["Foundation"])
        XCTAssertEqual(declaration.description, source)
    }

    func testComplexImportDeclaration() throws {
        let source = #"""
        import struct SwiftSemantics.Import
        """#

        let declarations = try SyntaxParser.declarations(of: Import.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertEqual(declaration.kind, "struct")
        XCTAssertEqual(declaration.pathComponents, ["SwiftSemantics", "Import"])
        XCTAssertEqual(declaration.description, source)
    }

    static var allTests = [
        ("testSimpleImportDeclaration", testSimpleImportDeclaration),
        ("testComplexImportDeclaration", testComplexImportDeclaration),
    ]
}


@testable import SwiftSemantics
import SwiftSyntax
import XCTest

final class ExtensionTests: XCTestCase {
    func testExtensionDeclarationWithGenericRequirements() throws {
        let source = #"""
        extension Array where Element == String, Element: StringProtocol {}
        """#

        let declarations = try SyntaxParser.declarations(of: Extension.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertEqual(declaration.extendedType, "Array")
        XCTAssertEqual(declaration.genericRequirements.map { $0.description }, ["Element == String", "Element: StringProtocol"])
    }

    func testFunctionDeclarationWithinExtension() throws {
        let source = #"""
        extension Collection {
            var hasAny: Bool { !isEmpty }
        }
        """#
        let extensions = try SyntaxParser.declarations(of: Extension.self, source: source)
        XCTAssertEqual(extensions.count, 1)

        let properties = try SyntaxParser.declarations(of: Variable.self, source: source)
        XCTAssertEqual(properties.count, 1)
        let property = properties.first!

        XCTAssertEqual(property.context, "Collection")
    }

    func testFunctionDeclarationWithinConstrainedExtension() throws {
        let source = #"""
        extension Collection where Element: Comparable {
            func hasAny(lessThan element: Element) -> Bool {
                guard !isEmpty else { return false }
                return sorted().first < element
            }
        }
        """#

        let extensions = try SyntaxParser.declarations(of: Extension.self, source: source)
        XCTAssertEqual(extensions.count, 1)
        XCTAssertEqual(extensions[0].genericRequirements.count, 1)
        XCTAssertEqual(extensions[0].genericRequirements[0].leftTypeIdentifier, "Element")
        XCTAssertEqual(extensions[0].genericRequirements[0].rightTypeIdentifier, "Comparable")

        let functions = try SyntaxParser.declarations(of: Function.self, source: source)
        XCTAssertEqual(functions.count, 1)
        XCTAssertEqual(functions[0].context, "Collection")
    }

    func testinheritanceInConstrainedExtension() throws {
        let source = #"""
        extension Collection: Hashable where Element: Hashable {}
        """#

        let extensions = try SyntaxParser.declarations(of: Extension.self, source: source)
        XCTAssertEqual(extensions.count, 1)

        XCTAssertEqual(extensions[0].genericRequirements.count, 1)
        XCTAssertEqual(extensions[0].genericRequirements[0].leftTypeIdentifier, "Element")
        XCTAssertEqual(extensions[0].genericRequirements[0].rightTypeIdentifier, "Hashable")

        XCTAssertEqual(extensions[0].inheritance.count, 1)
        XCTAssertEqual(extensions[0].inheritance[0], "Hashable")
    }

    static var allTests = [
        ("testExtensionDeclarationWithGenericRequirements", testExtensionDeclarationWithGenericRequirements),
        ("testFunctionDeclarationWithinExtension", testFunctionDeclarationWithinExtension),
        ("testFunctionDeclarationWithinConstrainedExtension", testFunctionDeclarationWithinConstrainedExtension),
        ("testinheritanceInConstrainedExtension", testinheritanceInConstrainedExtension),
    ]
}


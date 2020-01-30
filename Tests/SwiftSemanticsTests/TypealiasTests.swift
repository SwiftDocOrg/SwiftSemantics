@testable import SwiftSemantics
import SwiftSyntax
import XCTest

final class TypealiasTests: XCTestCase {
    func testTypealiasDeclarationsWithGenericParameter() throws {
        let source = #"""
        typealias SortableArray<T: Comparable> = Array<T>
        """#

        let declarations = try SyntaxParser.declarations(of: Typealias.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let `typealias` = declarations.first!

        XCTAssertNil(`typealias`.context)
        XCTAssertEqual(`typealias`.attributes.count, 0)
        XCTAssertEqual(`typealias`.name, "SortableArray")
        XCTAssertEqual(`typealias`.genericParameters.count, 1)
        XCTAssertEqual(`typealias`.genericParameters[0].name, "T")
        XCTAssertEqual(`typealias`.genericParameters[0].type, "Comparable")
        XCTAssertEqual(`typealias`.initializedType, "Array<T>")
        XCTAssertEqual(`typealias`.description, source)
    }

    func testTypealiasDeclarationsWithGenericRequirement() throws {
        let source = #"""
        typealias ArrayOfNumbers<T> = Array<T> where T: Numeric
        """#

        let declarations = try SyntaxParser.declarations(of: Typealias.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let `typealias` = declarations.first!

        XCTAssertNil(`typealias`.context)
        XCTAssertEqual(`typealias`.attributes.count, 0)
        XCTAssertEqual(`typealias`.name, "ArrayOfNumbers")
        XCTAssertEqual(`typealias`.genericParameters.count, 1)
        XCTAssertEqual(`typealias`.genericParameters[0].name, "T")
        XCTAssertNil(`typealias`.genericParameters[0].type)
        XCTAssertEqual(`typealias`.initializedType, "Array<T>")
        XCTAssertEqual(`typealias`.genericRequirements.count, 1)
        XCTAssertEqual(`typealias`.genericRequirements[0].leftTypeIdentifier, "T")
        XCTAssertEqual(`typealias`.genericRequirements[0].relation, .conformance)
        XCTAssertEqual(`typealias`.genericRequirements[0].rightTypeIdentifier, "Numeric")
    }

    static var allTests = [
        ("testTypealiasDeclarationsWithGenericParameter", testTypealiasDeclarationsWithGenericParameter),
        ("testTypealiasDeclarationsWithGenericRequirement", testTypealiasDeclarationsWithGenericRequirement),
    ]
}


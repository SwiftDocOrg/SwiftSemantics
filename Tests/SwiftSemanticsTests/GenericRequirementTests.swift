@testable import SwiftSemantics
import SwiftSyntax
import XCTest

final class GenericRequirementTests: XCTestCase {
    func testGenericRequirementsInFunction() throws {
        let source = #"""
        func difference<C1: Collection, C2: Collection>(between lhs: C1, and rhs: C2) -> [C1.Element]
            where C1.Element: Equatable, C1.Element == C2.Element
        """#

        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let function = declarations.first!
        XCTAssertEqual(function.genericRequirements.count, 2)

        XCTAssertEqual(function.genericRequirements[0].leftTypeIdentifier, "C1.Element")
        XCTAssertEqual(function.genericRequirements[0].relation, .conformance)
        XCTAssertEqual(function.genericRequirements[0].rightTypeIdentifier, "Equatable")
        XCTAssertEqual(function.genericRequirements[0].description, "C1.Element: Equatable")

        XCTAssertEqual(function.genericRequirements[1].leftTypeIdentifier, "C1.Element")
        XCTAssertEqual(function.genericRequirements[1].relation, .sameType)
        XCTAssertEqual(function.genericRequirements[1].rightTypeIdentifier, "C2.Element")
        XCTAssertEqual(function.genericRequirements[1].description, "C1.Element == C2.Element")
    }

    static var allTests = [
        ("testGenericRequirementsInFunction", testGenericRequirementsInFunction),
    ]
}


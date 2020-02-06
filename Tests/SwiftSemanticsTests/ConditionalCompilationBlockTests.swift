@testable import SwiftSemantics
import SwiftSyntax
import XCTest

final class ConditionalCompilationBlockTests: XCTestCase {
    func testConditionalCompilationBlock() throws {
        let source = #"""
        #if compiler(>=5) && os(Linux)
        enum A {}
        #elseif swift(>=4.2)
        enum B {}
        #else
        enum C {}
        #endif
        """#

        let declarations = try SyntaxParser.declarations(of: ConditionalCompilationBlock.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let conditionalCompilationBlock = declarations.first!

        XCTAssertEqual(conditionalCompilationBlock.branches.count, 3)

        XCTAssertEqual(conditionalCompilationBlock.branches[0].keyword, "#if")
        XCTAssertEqual(conditionalCompilationBlock.branches[0].condition, "compiler(>=5) && os(Linux)")

        XCTAssertEqual(conditionalCompilationBlock.branches[1].keyword, "#elseif")
        XCTAssertEqual(conditionalCompilationBlock.branches[1].condition, "swift(>=4.2)")

        XCTAssertEqual(conditionalCompilationBlock.branches[2].keyword, "#else")
        XCTAssertNil(conditionalCompilationBlock.branches[2].condition)
    }

    static var allTests = [
        ("testConditionalCompilationBlock", testConditionalCompilationBlock),
    ]
}


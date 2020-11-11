@testable import SwiftSemantics
import SwiftSyntax
import XCTest

final class DeclarationCollectorTests: XCTestCase {
    func testDeclarationCollector() throws {
        let source = #"""
        import UIKit

        class ViewController: UIViewController, UITableViewDelegate {
            enum Section: Int {
                case summary, people, places
            }

            var people: [People], places: [Place]

            @IBOutlet private(set) var tableView: UITableView!
        }

        """#

        let collector = DeclarationCollector()
        let tree = try SyntaxParser.parse(source: source)
        collector.walk(tree)

        XCTAssertEqual(collector.imports.count, 1)
        XCTAssertEqual(collector.imports.first?.pathComponents, ["UIKit"])

        XCTAssertEqual(collector.classes.count, 1)
        XCTAssertEqual(collector.classes.first?.name, "ViewController")
        XCTAssertEqual(collector.classes.first?.inheritance, ["UIViewController", "UITableViewDelegate"])

        XCTAssertEqual(collector.enumerations.count, 1)
        XCTAssertEqual(collector.enumerations.first?.name, "Section")
        XCTAssertEqual(collector.enumerations.first?.inheritance, ["Int"])

        XCTAssertEqual(collector.enumerationCases.count, 3)
        XCTAssertEqual(collector.enumerationCases.map { $0.name }, ["summary", "people", "places"])

        XCTAssertEqual(collector.variables.count, 3)
        XCTAssertEqual(collector.variables[0].name, "people")
        XCTAssertEqual(collector.variables[0].typeAnnotation, "[People]")
        XCTAssertEqual(collector.variables[1].name, "places")
        XCTAssertEqual(collector.variables[1].typeAnnotation, "[Place]")
        XCTAssertEqual(collector.variables[2].name, "tableView")
        XCTAssertEqual(collector.variables[2].typeAnnotation, "UITableView!")
        XCTAssertEqual(collector.variables[2].attributes.first?.name, "IBOutlet")
        XCTAssertEqual(collector.variables[2].modifiers.first?.name, "private")
        XCTAssertEqual(collector.variables[2].modifiers.first?.detail, "set")
    }

    static var allTests = [
        ("testDeclarationCollector", testDeclarationCollector),
    ]
}


import SwiftSyntax

extension SyntaxProtocol {
    var context: DeclSyntaxProtocol? {
        for case let node? in sequence(first: parent, next: { $0?.parent }) {
            guard let declaration = node.asProtocol(DeclSyntaxProtocol.self) else { continue }
            return declaration
        }

        return nil
    }
}

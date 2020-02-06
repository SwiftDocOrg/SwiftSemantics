import SwiftSyntax

extension Syntax {
    var context: DeclSyntax? {
        guard let parent = parent else { return nil }
        for case let declaration as DeclSyntax in sequence(first: parent, next: { $0.parent }) {
            return declaration
        }

        return nil
    }
}

import SwiftSyntax

extension DeclSyntax {
    var name: String? {
        switch self {
        case let syntax as ClassDeclSyntax:
            return syntax.identifier.withoutTrivia().text
        case let syntax as EnumDeclSyntax:
            return syntax.identifier.withoutTrivia().text
        case let syntax as ExtensionDeclSyntax:
            return syntax.extendedType.description.trimmed
        case let syntax as ProtocolDeclSyntax:
            return syntax.identifier.withoutTrivia().text
        case let syntax as StructDeclSyntax:
            return syntax.identifier.withoutTrivia().text
        default:
            return nil
        }
    }

    var ancestors: [DeclSyntax] {
        guard let context = context else { return [] }
        return Array(sequence(first: context, next: { $0.context }))
    }
}

extension Syntax {
    var context: DeclSyntax? {
        guard let parent = parent else { return nil }
        for case let declaration as DeclSyntax in sequence(first: parent, next: { $0.parent }) {
            return declaration
        }

        return nil
    }
}

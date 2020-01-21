import SwiftSyntax

/// An import declaration.
public struct Import: Declaration, Hashable, Codable {
    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The import keyword (`"import"`).
    public let keyword: String

    public let kind: String?
    public let pathComponents: [String]
}

// MARK: - ExpressibleBySyntax

extension Import: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: ImportDeclSyntax) {
        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.importTok.withoutTrivia().text
        kind = node.importKind?.withoutTrivia().text
        pathComponents = node.path.tokens.filter { $0.tokenKind != .period }.map { $0.withoutTrivia().text }
    }
}

// MARK: - CustomStringConvertible

extension Import: CustomStringConvertible {
    public var description: String {
        return (
            attributes.map { $0.description } +
            modifiers.map { $0.description } +
            [keyword, kind] +
            [pathComponents.joined(separator: ".")]
        ).compactMap { $0 }.joined(separator: " ")
    }
}

import SwiftSyntax

/// An associated type declaration.
public struct AssociatedType: Declaration, Hashable, Codable {
    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"associatedtype"`).
    public let keyword: String

    /// The associated type name.
    public let name: String
}

// MARK: - ExpressibleBySyntax

extension AssociatedType: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: AssociatedtypeDeclSyntax) {
        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.associatedtypeKeyword.withoutTrivia().text
        name = node.identifier.withoutTrivia().text
    }
}

// MARK: - CustomStringConvertible

extension AssociatedType: CustomStringConvertible {
    public var description: String {
        return (
            attributes.map { $0.description } +
            modifiers.map { $0.description } +
            [keyword, name]
        ).joined(separator: " ")
    }
}

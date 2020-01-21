import SwiftSyntax

/// A protocol declaration.
public struct Protocol: Declaration, Hashable, Codable {
    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"protocol"`).
    public let keyword: String

    /// The protocol name.
    public let name: String

    /**
     A list of adopted protocols.

     For example,
     given the following declarations,
     the `inheritance` of protocol `P` is `["Q"]`:

     ```swift
     protocol Q {}
     protocol P: Q {}
     ```
    */
    public let inheritance: [String]
}

// MARK: - ExpressibleBySyntax

extension Protocol: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: ProtocolDeclSyntax) {
        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.protocolKeyword.withoutTrivia().text
        name = node.identifier.withoutTrivia().text
        inheritance = node.inheritanceClause?.inheritedTypeCollection.map { $0.withoutTrivia().typeName.description.trimmed } ?? []
    }
}

// MARK: - CustomStringConvertible

extension Protocol: CustomStringConvertible {
    public var description: String {
        var description = (
            attributes.map { $0.description } +
            modifiers.map { $0.description } +
            [keyword, name]
        ).joined(separator: " ")

        if !inheritance.isEmpty {
            description += ": \(inheritance.joined(separator: ", "))"
        }

        return description
    }
}

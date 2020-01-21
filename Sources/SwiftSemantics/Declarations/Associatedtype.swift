import SwiftSyntax

/// An associated type declaration.
public struct AssociatedType: Declaration, Hashable, Codable {
    /**
    A dot-delimited (`.`) path used to qualify the associated type name
    within the module scope of the declaration.

    For example,
    given the following declaration of an associated type `T`,
    the `context` is `"P"`:

    ```swift
    protocol P { associatedtype T }
    ```
    */
    public let context: String?
    
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
        context = node.ancestors.compactMap { $0.name }.reversed().joined(separator: ".").nonEmpty
        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.associatedtypeKeyword.withoutTrivia().text
        name = node.identifier.withoutTrivia().text
    }
}

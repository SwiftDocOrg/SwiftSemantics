import SwiftSyntax

/// A subscript declaration.
public struct Subscript: Declaration, Hashable, Codable {
    public let context: String?

    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"subscript"`).
    public let keyword: String

    /// The subscript name.
    public let name: String
    
    /**
     The generic parameters for the declaration.

     For example,
     the following subscript declaration
     has a single generic parameter
     whose `name` is `"T"` and `type` is `"Equatable"`:

     ```swift
     subscript<T: Equatable>(value: T) {}
     ```
     */
    public let genericParameters: [GenericParameter]

    /**
     The generic parameter requirements for the declaration.

     For example,
     the following subscript declaration
     has a single requirement
     that its generic parameter identified as `"T"`
     conforms to the type identified as `"Hahable"`:

     ```swift
     subscript<T>(value: T) where T: Hashable {}
     ```
     */
    public let genericRequirements: [GenericRequirement]

    /// The subscript getter and/or setter.
    public let accessors: [Variable.Accessor]
}

// MARK: - ExpressibleBySyntax

extension Subscript: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: SubscriptDeclSyntax) {
        context = node.ancestors.compactMap { $0.name }.reversed().joined(separator: ".").nonEmpty
        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.subscriptKeyword.withoutTrivia().text
        name = node.name ?? ""
        genericParameters = node.genericParameterClause?.genericParameterList.map { GenericParameter($0) } ?? []
        genericRequirements = GenericRequirement.genericRequirements(from: node.genericWhereClause?.requirementList)
        accessors = Variable.Accessor.accessors(from: node.accessor as? AccessorBlockSyntax)
    }
}

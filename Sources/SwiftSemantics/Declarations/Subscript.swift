import SwiftSyntax

/// A subscript declaration.
public struct Subscript: Declaration, Hashable, Codable {
    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"subscript"`).
    public let keyword: String

    /// The subscript indices.
    public let indices: [Function.Parameter]
    
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

    /// The return type of the subscript.
    public let returnType: String

    /// The subscript getter and/or setter.
    public let accessors: [Variable.Accessor]
}

// MARK: - ExpressibleBySyntax

extension Subscript: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: SubscriptDeclSyntax) {
        attributes = node.attributes?.compactMap{ $0.as(AttributeSyntax.self) }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.subscriptKeyword.text.trimmed
        indices = node.indices.parameterList.map { Function.Parameter($0) }
        genericParameters = node.genericParameterClause?.genericParameterList.map { GenericParameter($0) } ?? []
        returnType = node.result.returnType.description.trimmed
        genericRequirements = GenericRequirement.genericRequirements(from: node.genericWhereClause?.requirementList)
        accessors = Variable.Accessor.accessors(from: node.accessor?.as(AccessorBlockSyntax.self))
    }
}

// MARK: - CustomStringConvertible

extension Subscript: CustomStringConvertible {
    public var description: String {
        var description = (
            attributes.map { $0.description } +
                modifiers.map { $0.description } +
                [keyword]
            ).joined(separator: " ")

        if !genericParameters.isEmpty {
            description += "<\(genericParameters.map { $0.description }.joined(separator: ", "))>"
        }

        description += "(\(indices.map { $0.description }.joined(separator: ", ")))"

        if !genericRequirements.isEmpty {
            description += " where \(genericRequirements.map { $0.description }.joined(separator: ", "))"
        }

        description += " -> \(returnType)"

        return description
    }

}


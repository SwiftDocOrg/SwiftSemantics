import SwiftSyntax

/// A structure declaration.
public struct Structure: Declaration, Hashable, Codable {
    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"struct"`).
    public let keyword: String

    /// The structure name.
    public let name: String

    /**
     A list of adopted protocols.

     For example,
     given the following declarations,
     the `inheritance` of structure `S` is `["P", "Q"]`:

     ```swift
     protocol P {}
     protocol Q {}
     struct S {}
     ```
     */
    public let inheritance: [String]

    /**
     The generic parameters for the declaration.

     For example,
     the following declaration of structure `S`
     has a single generic parameter
     whose `name` is `"T"` and `type` is `"Equatable"`:

     ```swift
     struct S<T: Equatable> {}
     ```
     */
    public let genericParameters: [GenericParameter]

    /**
     The generic parameter requirements for the declaration.

     For example,
     the following declaration of structure `S`
     has a single requirement
     that its generic parameter identified as `"T"`
     conforms to the type identified as `"Hahable"`:

     ```swift
     struct S<T> where T: Hashable {}
     ```
     */
    public let genericRequirements: [GenericRequirement]
}

// MARK: - ExpressibleBySyntax

extension Structure: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: StructDeclSyntax) {
        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.structKeyword.text.trimmed
        name = node.identifier.text.trimmed
        inheritance = node.inheritanceClause?.inheritedTypeCollection.map { $0.typeName.description.trimmed } ?? []
        genericParameters = node.genericParameterClause?.genericParameterList.map { GenericParameter($0) } ?? []
        genericRequirements = GenericRequirement.genericRequirements(from: node.genericWhereClause?.requirementList)
    }
}

// MARK: - CustomStringConvertible

extension Structure: CustomStringConvertible {
    public var description: String {
        var description = (
            attributes.map { $0.description } +
            modifiers.map { $0.description } +
            [keyword, name]
        ).joined(separator: " ")

        if !genericParameters.isEmpty {
            description += "<\(genericParameters.map { $0.description }.joined(separator: ", "))>"
        }

        if !inheritance.isEmpty {
            description += ": \(inheritance.joined(separator: ", "))"
        }

        if !genericRequirements.isEmpty {
            description += " where \(genericRequirements.map { $0.description }.joined(separator: ", "))"
        }

        return description
    }
}

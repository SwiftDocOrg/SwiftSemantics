import SwiftSyntax

/// An extension declaration.
public struct Extension: Declaration, Hashable, Codable {
    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"extension"`).
    public let keyword: String

    /// The name of the type extended by the extension.
    public let extendedType: String

    /**
     A list of protocol names inherited by the extended type.

     For example,
     the following extension on structure `S`
     has an `inheritance` of `["P", "Q"]`:

     ```swift
     struct S {}
     protocol P {}
     protocol Q {}
     extension S: P, Q {}
    ```
    */
    public let inheritance: [String]

    /**
     The generic parameter requirements for the declaration.

     For example,
     the following conditional extension on structure S
     has a single requirement
     that its generic parameter identified as `"T"`
     conforms to the type identified as `"Hahable"`:

     ```swift
     struct S<T> {}
     extension S where T: Hashable {}
     ```
     */
    public let genericRequirements: [GenericRequirement]
}

// MARK: - ExpressibleBySyntax

extension Extension: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: ExtensionDeclSyntax) {
        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.extensionKeyword.text.trimmed
        extendedType = node.extendedType.description.trimmed
        inheritance = node.inheritanceClause?.inheritedTypeCollection.map { $0.typeName.description.trimmed } ?? []
        genericRequirements = GenericRequirement.genericRequirements(from: node.genericWhereClause?.requirementList)
    }
}

// MARK: - CustomStringConvertible

extension Extension: CustomStringConvertible {
    public var description: String {
         var description = (
             attributes.map { $0.description } +
             modifiers.map { $0.description } +
             [keyword]
         ).joined(separator: " ")

         if !genericRequirements.isEmpty {
             description += " where \(genericRequirements.map { $0.description }.joined(separator: ", "))"
         }

         return description
     }
}

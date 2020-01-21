import SwiftSyntax

/// A class declaration.
public struct Class: Declaration, Hashable, Codable {
    /**
    A dot-delimited (`.`) path used to qualify the class name
    within the module scope of the declaration,
    or `nil` if the class isn't nested
    (that is, declared at the top-level scope of a module).

    For example,
    given the following declaration of a class `C`,
    the `context` is `"A.B"`:

    ```swift
    class A { class B { class C {} }
    ```
    */
    public let context: String?

    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"class"`).
    public let keyword: String

    /// The class name.
    public let name: String

    /**
     A list of inherited type names.

     If the class is a subclass,
     the first element is the superclass.
     Any other elements are names of protocols.

     For example,
     given the following declarations,
     the `inheritance` of class `C` is `["B", "P"]`:

     ```swift
     protocol P {}
     class A {}
     class B: A {}
     class C: B, P {}
     ```
     */
    public let inheritance: [String]

    /**
     The generic parameters for the declaration.

     For example,
     the following declaration of class `C`
     has a single generic parameter
     whose `name` is `"T"` and `type` is `"Equatable"`:

     ```swift
     class C<T: Equatable> {}
     ```
     */
    public let genericParameters: [GenericParameter]

    /**
     The generic parameter requirements for the declaration.

     For example,
     the following declaration of class `C`
     has a single requirement
     that its generic parameter identified as `"T"`
     conforms to the type identified as `"Hahable"`:

     ```swift
     class C<T> where T: Hashable {}
     ```
     */
    public let genericRequirements: [GenericRequirement]
}

// MARK: - ExpressibleBySyntax

extension Class: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: ClassDeclSyntax) {
        context = node.ancestors.compactMap { $0.name }.reversed().joined(separator: ".").nonEmpty
        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.classKeyword.withoutTrivia().text
        name = node.identifier.withoutTrivia().text
        inheritance = node.inheritanceClause?.inheritedTypeCollection.map { $0.withoutTrivia().typeName.description.trimmed } ?? []
        genericParameters = node.genericParameterClause?.genericParameterList.map { GenericParameter($0) } ?? []
        genericRequirements = GenericRequirement.genericRequirements(from: node.genericWhereClause?.requirementList)
    }
}

// MARK: - CustomStringConvertible

extension Class: CustomStringConvertible {
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

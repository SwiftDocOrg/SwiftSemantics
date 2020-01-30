import SwiftSyntax

/// A type alias declaration.
public struct Typealias: Declaration, Hashable, Codable {
    public let context: String?

    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"typealias"`).
    public let keyword: String

    /// The type alias name.
    public let name: String

    /// The initialized type, if any.
    public let initializedType: String?

    /**
     The generic parameters for the declaration.

     For example,
     the following typealias declaration
     has a single generic parameter
     whose `name` is `"T"` and `type` is `"Comparable"`:

     ```swift
     typealias SortableArray<T: Comparable> = Array<T>
     ```
     */
    public let genericParameters: [GenericParameter]

    /**
     The generic parameter requirements for the declaration.

     For example,
     the following typealias declaration
     has a single requirement
     that its generic parameter identified as `"T"`
     conforms to the type identified as `"Numeric"`:

     ```swift
     typealias ArrayOfNumbers<T> = Array<T> where T: Numeric
     ```
     */
    public let genericRequirements: [GenericRequirement]
}

// MARK: - ExpressibleBySyntax

extension Typealias: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: TypealiasDeclSyntax) {
        context = node.ancestors.compactMap { $0.name }.reversed().joined(separator: ".").nonEmpty
        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.typealiasKeyword.withoutTrivia().text
        name = node.identifier.withoutTrivia().text
        initializedType = node.initializer?.value.description.trimmed
        genericParameters = node.genericParameterClause?.genericParameterList.map { GenericParameter($0) } ?? []
        genericRequirements = GenericRequirement.genericRequirements(from: node.genericWhereClause?.requirementList)
    }
}

// MARK: - CustomStringConvertible

extension Typealias: CustomStringConvertible {
    public var description: String {
        var description = (
        attributes.map { $0.description } +
            modifiers.map { $0.description } +
            [keyword, name]
        ).joined(separator: " ")

        if !genericParameters.isEmpty {
            description += "<\(genericParameters.map { $0.description }.joined(separator: ", "))>"
        }

        if let initializedType = initializedType {
            description += " = \(initializedType)"
        }

        if !genericRequirements.isEmpty {
            description += " where \(genericRequirements.map { $0.description }.joined(separator: ", "))"
        }

        return description
    }
}

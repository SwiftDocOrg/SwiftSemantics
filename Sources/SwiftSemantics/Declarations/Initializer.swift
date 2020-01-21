import SwiftSyntax

/// An initializer declaration.
public struct Initializer: Declaration, Hashable, Codable {
    public let context: String?

    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"associatedtype"`).
    public let keyword: String

    /// Whether the initializer is optional.
    public let optional: Bool

    /**
     The generic parameters for the declaration.

     For example,
     the following initializer declaration
     has a single generic parameter
     whose `name` is `"T"` and `type` is `"Equatable"`:

     ```swift
     init<T: Equatable>(value: T) {}
     ```
     */
    public let genericParameters: [GenericParameter]

    /// The initializer inputs.
    public let parameters: [Function.Parameter]

    /// The `throws` or `rethrows` keyword, if any.
    public let throwsOrRethrowsKeyword: String?

    /**
     The generic parameter requirements for the declaration.

     For example,
     the following initializer declaration
     has a single requirement
     that its generic parameter identified as `"T"`
     conforms to the type identified as `"Hahable"`:

     ```swift
     init<T>(value: T) where T: Hashable {}
     ```
     */
    public let genericRequirements: [GenericRequirement]
}

// MARK: - ExpressibleBySyntax

extension Initializer: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: InitializerDeclSyntax) {
        context = node.ancestors.compactMap { $0.name }.reversed().joined(separator: ".").nonEmpty
        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.initKeyword.withoutTrivia().text
        optional = node.optionalMark != nil
        genericParameters = node.genericParameterClause?.genericParameterList.map { GenericParameter($0) } ?? []
        parameters = node.parameters.parameterList.map { Function.Parameter($0) }
        throwsOrRethrowsKeyword = node.throwsOrRethrowsKeyword?.description
        genericRequirements = GenericRequirement.genericRequirements(from: node.genericWhereClause?.requirementList)
    }
}

// MARK: - CustomStringConvertible

extension Initializer: CustomStringConvertible {
    public var description: String {
        var description = (
            attributes.map { $0.description } +
            modifiers.map { $0.description } +
            [keyword]
        ).joined(separator: " ")

        if optional {
            description += "?"
        }

        if !genericParameters.isEmpty {
            description += "<\(genericParameters.map { $0.description }.joined(separator: ", "))>"
        }

        description += "(\(parameters.map { $0.description }.joined(separator: ", ")))"
        if let throwsOrRethrowsKeyword = throwsOrRethrowsKeyword {
            description += " \(throwsOrRethrowsKeyword)"
        }

        if !genericRequirements.isEmpty {
            description += " where \(genericRequirements.map { $0.description }.joined(separator: ", "))"
        }

        return description
    }
}

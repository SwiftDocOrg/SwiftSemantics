import SwiftSyntax

/**
 A generic parameter.

 A generic type or function declaration includes a generic parameter clause,
 consisting of one or more generic parameters enclosed by angle brackets (`<>`).
 Each generic parameter has a name,
 and may also specify a type constraint.
 For example,
 the following structure declaration has two generic parameters:

 ```swift
 struct S<T, U: Equatable>
 ```

 - The first generic parameter is named `"T"`
   and has no type constraint.
 - The second generic parameter is named `"U"`
   and a type constraint on `"Equatable"`.
 */
public struct GenericParameter: Hashable, Codable {
    /// The generic parameter attributes.
    public let attributes: [Attribute]

    /// The generic parameter name.
    public let name: String

    /// The generic parameter type, if any.
    public let type: String?
}

// MARK: - ExpressibleBySyntax

extension GenericParameter: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: GenericParameterSyntax) {
        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        name = node.name.text.trimmed
        type = node.inheritedType?.description
    }
}

// MARK: - CustomStringConvertible

extension GenericParameter: CustomStringConvertible {
    public var description: String {
        var description: String = (attributes.map { $0.description } + [name]).joined(separator: " ")
        if let type = type {
            description += ": \(type)"
        }

        return description
    }
}


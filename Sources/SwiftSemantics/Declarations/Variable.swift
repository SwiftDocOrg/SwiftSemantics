import SwiftSyntax

/// A declaration for a property or a top-level variable or constant.
public struct Variable: Declaration, Hashable, Codable {
    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"let"` or `"var"`).
    public let keyword: String

    /// The name of the property or top-level variable or constant.
    public let name: String

    /// The type annotation for the declaration, if any.
    public let typeAnnotation: String?

    /// The initialized value for the declaration, if any.
    public let initializedValue: String?

    /// The variable or property accessors.
    public let accessors: [Accessor]

    /// A computed variable or computed property accessor.
    public struct Accessor: Hashable, Codable {
        /// The kind of accessor (`get` or `set`).
        public enum Kind: String, Hashable, Codable {
            /// A getter that returns a value.
            case get

            /// A setter that sets a value.
            case set
        }

        /// The accessor attributes.
        public let attributes: [Attribute]

        /// The accessor modifiers.
        public let modifier: Modifier?

        /// The kind of accessor.
        public let kind: Kind?
    }
}

// MARK: - ExpressibleBySyntax

extension Variable: ExpressibleBySyntax {
    /**
     Creates and returns variables from a variable declaration,
     which may contain one or more pattern bindings,
     such as `let x: Int = 1, y: Int = 2`.
     */
    public static func variables(from node: VariableDeclSyntax) -> [Variable] {
        return node.bindings.compactMap { Variable($0) }
    }

    /// Creates an instance initialized with the given syntax node.
    public init?(_ node: PatternBindingSyntax) {
        guard let parent = node.context as? VariableDeclSyntax else {
            preconditionFailure("PatternBindingSyntax should be contained within VariableDeclSyntax")
            return nil
        }

        attributes = parent.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifiers = parent.modifiers?.map { Modifier($0) } ?? []
        keyword = parent.letOrVarKeyword.text.trimmed
        name = node.pattern.description.trimmed
        typeAnnotation = node.typeAnnotation?.type.description.trimmed
        initializedValue = node.initializer?.value.description.trimmed
        accessors = Accessor.accessors(from: node.accessor as? AccessorBlockSyntax)
    }
}

extension Variable.Accessor: ExpressibleBySyntax {
    public static func accessors(from node: AccessorBlockSyntax?) -> [Variable.Accessor] {
        guard let node = node else { return [] }
        return node.accessors.compactMap { Variable.Accessor(accessor: $0) }
    }

    /// Creates an instance initialized with the given syntax node.
    @available(swift, introduced: 0.0.1, deprecated: 0.0.1, message: "Use Variable.Accessor.accessors(from:) instead")
    public init(_ node: AccessorDeclSyntax) {
        self.init(accessor: node)!
    }

    private init?(accessor node: AccessorDeclSyntax) {
        let rawValue = node.accessorKind.text.trimmed
        if rawValue.isEmpty {
            self.kind = nil
        } else if let kind = Kind(rawValue: rawValue) {
            self.kind = kind
        } else {
            return nil
        }

        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifier = node.modifier.map { Modifier($0) }
    }
}

// MARK: - CustomStringConvertible

extension Variable: CustomStringConvertible {
    public var description: String {
        switch (self.typeAnnotation, self.initializedValue) {
        case let (typeAnnotation?, initializedValue?):
            return "\(keyword) \(name): \(typeAnnotation) = \(initializedValue)"
        case let (typeAnnotation?, _):
            return "\(keyword) \(name): \(typeAnnotation)"
        case let (_, initializedValue?):
            return "\(keyword) \(name) = \(initializedValue)"
        default:
            return "\(keyword) \(name)"
        }
    }
}


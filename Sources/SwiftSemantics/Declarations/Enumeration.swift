import SwiftSyntax

/// An enumeration declaration.
public struct Enumeration: Declaration, Hashable, Codable {
    /**
     A dot-delimited (`.`) path used to qualify the enumeration name
     within the module scope of the declaration,
     or `nil` if the enumeration isn't nested
     (that is, declared at the top-level scope of a module).

     For example,
     given the following declaration of an enumeration `C`,
     the `context` is `"A.B"`:

     ```swift
     enum A { enum B { enum C {} }
     ```
     */
    public let context: String?

    /// The enumeration declaration attributes.
    public let attributes: [Attribute]

    /// The enumeration declaration modifiers.
    public let modifiers: [Modifier]

    /// The enumeration declaration keyword (`enum`).
    public let keyword: String

    /// The name of the enumeration.
    public let name: String

    /**
     A list of inherited type names.

     If the enumeration is raw representable,
     the first element is the raw value type.
     Any other elements are names of protocols.

     For example,
     given the following declarations,
     the `inheritance` of enumeration `E` is `["Int", "P"]`:

     ```swift
     protocol P {}
     enum E: Int, P {}
     ```
     */
    public let inheritance: [String]

    /**
     The generic parameters for the declaration.

     For example,
     the following declaration of enumeration `E`
     has a single generic parameter
     whose `name` is `"T"` and `type` is `"Equatable"`:

     ```swift
     enum E<T: Equatable> {}
     ```
     */
    public let genericParameters: [GenericParameter]

    /**
     The generic parameter requirements for the declaration.

     For example,
     the following declaration of enumeration `E`
     has a single requirement
     that its generic parameter identified as `"T"`
     conforms to the type identified as `"Hahable"`:

     ```swift
     enum E<T> where T: Hashable {}
     ```
     */
    public let genericRequirements: [GenericRequirement]

    /// An enumeration case.
    public struct Case: Declaration, Hashable, Codable {
        /**
        A dot-delimited (`.`) path used to qualify the enumeration case name
        within the module scope of the declaration,
        or `nil` if the containing enumeration isn't nested
        (that is, declared at the top-level scope of a module).

        For example,
        given the following declaration of case `C.c`
        the `context` is `"A.B"`:

        ```swift
        enum A { enum B { enum C { case c } }
        ```
        */
        public let context: String?

        /// The declaration attributes.
        public let attributes: [Attribute]

        /// The declaration modifiers.
        public let modifiers: [Modifier]

        /// The declaration keyword (`"case"`).
        public let keyword: String

        /// The enumeration case name.
        public let name: String

        /// The associated values of the enumeration case, if any.
        public let associatedValue: [Function.Parameter]?

        /// The raw value of the enumeration case, if any.
        public let rawValue: String?
    }
}

// MARK: - CustomStringConvertible

extension Enumeration: CustomStringConvertible {
    public var description: String {
        var description = (
            attributes.map { $0.description } +
            modifiers.map { $0.description } +
            [keyword, name]
        ).joined(separator: " ")

        if !genericParameters.isEmpty {
            description += "<\(genericParameters.map { $0.description }.joined(separator: ", "))>"
        }

        if !genericRequirements.isEmpty {
            description += " where \(genericRequirements.map { $0.description }.joined(separator: ", "))"
        }

        return description
    }
}

extension Enumeration.Case: CustomStringConvertible {
    public var description: String {
        if let associatedValue = associatedValue {
            return "\(keyword) \(name)(\(associatedValue.map{"\($0)"}.joined(separator: ", ")))"
        } else {
            return "\(keyword) \(name)"
        }
    }
}

// MARK: - ExpressibleBySyntax

extension Enumeration: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: EnumDeclSyntax) {
        context = node.ancestors.compactMap { $0.name }.reversed().joined(separator: ".").nonEmpty
        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.enumKeyword.withoutTrivia().text
        name = node.identifier.withoutTrivia().text
        inheritance = node.inheritanceClause?.inheritedTypeCollection.map { $0.withoutTrivia().typeName.description.trimmed } ?? []
        genericParameters = node.genericParameters?.genericParameterList.map { GenericParameter($0) } ?? []
        genericRequirements = GenericRequirement.genericRequirements(from: node.genericWhereClause?.requirementList)
    }
}

extension Enumeration.Case {
    /// Creates and returns enumeration cases from an enumeration case declaration.
    public static func cases(from node: EnumCaseDeclSyntax) -> [Enumeration.Case] {
        return node.elements.compactMap { Enumeration.Case(element: $0) }
    }

    /// Creates an instance initialized with the given syntax node.
    @available(swift, introduced: 0.0.1, deprecated: 0.0.1, message: "Use Enumeration.Case.cases(from:) instead")
    public init(_ node: EnumCaseDeclSyntax) {
        self.init(element: Array(node.elements).first!)!
    }

    private init?(element node: EnumCaseElementSyntax) {
        guard let parent = node.context as? EnumCaseDeclSyntax else {
            assertionFailure("EnumCaseElement should be contained within EnumCaseDecl")
            return nil
        }

        context = parent.ancestors.compactMap { $0.name }.reversed().joined(separator: ".").nonEmpty
        attributes = parent.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifiers = parent.modifiers?.map { Modifier($0) } ?? []
        keyword = parent.caseKeyword.withoutTrivia().text

        name = node.identifier.withoutTrivia().text
        associatedValue = node.associatedValue?.parameterList.map { Function.Parameter($0) }
        rawValue = node.rawValue?.children.first { $0.isExpr }?.description
    }
}

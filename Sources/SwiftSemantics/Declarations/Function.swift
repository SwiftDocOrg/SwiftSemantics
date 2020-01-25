import SwiftSyntax

/// A function declaration.
public struct Function: Declaration, Hashable, Codable {
    /**
     A dot-delimited (`.`) path used to qualify the function name
     within the module scope of the declaration,
     or `nil` if the function isn't nested
     (that is, declared at the top-level scope of a module).

     For example,
     given the following declaration of a function `greet`,
     the `context` is `"A.B"`:

     ```swift
     enum A { enum B { static func greet() {} }
     ```
    */
    public let context: String?

    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"func"`).
    public let keyword: String

    /// The function identifier.
    public let identifier: String

    /// The function signature.
    public let signature: Signature

    /**
     The generic parameters for the declaration.

     For example,
     the following declaration of function `f`
     has a single generic parameter
     whose `identifier` is `"T"` and `type` is `"Equatable"`:

     ```swift
     func f<T: Equatable>(value: T) {}
     ```
     */
    public let genericParameters: [GenericParameter]

    /**
     The generic parameter requirements for the declaration.

     For example,
     the following declaration of function `f`
     has a single requirement
     that its generic parameter identified as `"T"`
     conforms to the type identified as `"Hahable"`:

     ```swift
     func f<T>(value: T) where T: Hashable {}
     ```
     */
    public let genericRequirements: [GenericRequirement]

    /// Whether the function is an operator.
    public var isOperator: Bool {
        return Operator.Kind(modifiers) != nil || Operator.isValidIdentifier(identifier)
    }

    /// A function signature.
    public struct Signature: Hashable, Codable {
        /// The function inputs.
        public let input: [Parameter]

        /// The function output, if any.
        public let output: String?

        /// The `throws` or `rethrows` keyword, if any.
        public let throwsOrRethrowsKeyword: String?
    }

    /**
     A function parameter.

     This type can also be used to represent
     initializer parameters and associated values for enumeration cases.
     */
    public struct Parameter: Hashable, Codable {
        /// The declaration attributes.
        public let attributes: [Attribute]

        /**
         The first, external name of the parameter.

         For example,
         given the following function declaration,
         the first parameter has a `firstName` equal to `nil`,
         and the second parameter has a `firstName` equal to `"by"`:

         ```swift
         func increment(_ number: Int, by amount: Int = 1)
         ```
         */
        public let firstName: String?

        /**
         The second, internal name of the parameter.

         For example,
         given the following function declaration,
         the first parameter has a `secondName` equal to `"number"`,
         and the second parameter has a `secondName` equal to `"amount"`:

         ```swift
         func increment(_ number: Int, by amount: Int = 1)
         ```
        */
        public let secondName: String?

        /**
         The type identified by the parameter.

         For example,
         given the following function declaration,
         the first parameter has a `type` equal to `"Person"`,
         and the second parameter has a `type` equal to `"String"`:

         ```swift
         func greet(_ person: Person, with phrases: String...)
         ```
        */
        public let type: String?

        /**
         Whether the parameter accepts a variadic argument.

         For example,
         given the following function declaration,
         the second parameter is variadic:

         ```swift
         func greet(_ person: Person, with phrases: String...)
         ```
        */
        public let variadic: Bool

        /**
         The default argument of the parameter.

         For example,
         given the following function declaration,
         the second parameter has a default argument equal to `"1"`.

         ```swift
         func increment(_ number: Int, by amount: Int = 1)
         ```
         */
        public let defaultArgument: String?
    }
}

// MARK: - ExpressibleBySyntax

extension Function: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: FunctionDeclSyntax) {
        context = node.ancestors.compactMap { $0.name }.reversed().joined(separator: ".").nonEmpty
        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.funcKeyword.withoutTrivia().text
        identifier = node.identifier.withoutTrivia().text
        signature = Signature(node.signature)
        genericParameters = node.genericParameterClause?.genericParameterList.map { GenericParameter($0) } ?? []
        genericRequirements = GenericRequirement.genericRequirements(from: node.genericWhereClause?.requirementList)
    }
}

extension Function.Parameter: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: FunctionParameterSyntax) {
        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        firstName = node.firstName?.withoutTrivia().text
        secondName = node.secondName?.withoutTrivia().text
        type = node.type?.description.trimmed
        variadic = node.ellipsis != nil
        defaultArgument = node.defaultArgument?.value.description.trimmed
    }
}

extension Function.Signature: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: FunctionSignatureSyntax) {
        input = node.input.parameterList.map { Function.Parameter($0) }
        output = node.output?.returnType.description.trimmed
        throwsOrRethrowsKeyword = node.throwsOrRethrowsKeyword?.description
    }
}

// MARK: - CustomStringConvertible

extension Function: CustomStringConvertible {
    public var description: String {
        var description = (
            attributes.map { $0.description } +
            modifiers.map { $0.description } +
            [keyword, identifier]
        ).joined(separator: " ")

        if !genericParameters.isEmpty {
            description += "<\(genericParameters.map { $0.description }.joined(separator: ", "))>"
        }

        description += signature.description

        if !genericRequirements.isEmpty {
            description += " where \(genericRequirements.map { $0.description }.joined(separator: ", "))"
        }

        return description
    }
}

extension Function.Signature: CustomStringConvertible {
    public var description: String {
        var description = "(\(input.map { $0.description }.joined(separator: ", ")))"
        if let throwsOrRethrowsKeyword = throwsOrRethrowsKeyword {
            description += " \(throwsOrRethrowsKeyword)"
        }

        if let output = output {
            description += " -> \(output)"
        }

        return description
    }
}

extension Function.Parameter: CustomStringConvertible {
    public var description: String {
        var description: String = (attributes.map { $0.description } + [firstName, secondName].compactMap { $0?.description }).joined(separator: " ")
        if let type = type {
            description += ": \(type)"
        }

        if let defaultArgument = defaultArgument {
            description += " = \(defaultArgument)"
        }
        return description
    }
}

import SwiftSyntax

/**
 A declaration attribute.

 Attributes provide additional information about a declaration.
 For example,
 the `@discardableResult` attribute indicates that
 a function may be called without using the result.
 */
public struct Attribute: Hashable, Codable {
    /**
     The attribute name.

     An attribute's name is everything after the at-sign (`@`)
     and before the argument clause.
     For example,
     the name of the attribute in the following declaration is `"available"`:

     ```swift
     @available(macOS 10.15, iOS 13, *)
     ```
     */
    public let name: String

    /// The attribute's arguments, if any.
    public let arguments: [Argument]

    /**
     An attribute argument.

     Certain attributes take one or more arguments,
     each of which have a value and optional name.
     For example,
     the following attribute declaration has three arguments:

     ```swift
     @available(*, unavailable, message: "🚫")
     ```

     - The first argument is unnamed and has the value `"*"`
     - The second argument is unnamed and has the value `"unavailable"`
     - The third argument has the name "`renamed`" and the value `"🚫"`
     */
    public struct Argument: Hashable, Codable {
        /// The argument name, if any.
        public let name: String?

        /// The argument value.
        public let value: String

        static func arguments(from node: SwiftSyntax.Syntax?) -> [Argument] {
            guard let node = node else { return [] }
            return node.description.split(separator: ",").compactMap { token in
                let components = token.split(separator: ":", maxSplits: 1)
                if components.count == 2,
                    let name = components.first,
                    let value = components.last
                {
                    return Argument(name: name.trimmed, value: value.trimmed)
                } else if components.count == 1,
                    let value = components.last
                {
                    return Argument(name: nil, value: value.trimmed)
                } else {
                    assertionFailure("invalid argument token: \(token)")
                    return nil
                }
            }
        }
    }
}

// MARK: - ExpressibleBySyntax

extension Attribute: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: AttributeSyntax) {
        name = node.attributeName.withoutTrivia().text
        arguments = Argument.arguments(from: node.argument)
    }
}

// MARK: - CustomStringConvertible

extension Attribute: CustomStringConvertible {
    public var description: String {
        if arguments.isEmpty {
            return "@\(name)"
        } else {
            return "@\(name)(\(arguments.map { $0.description }.joined(separator: ", ")))"
        }
    }
}

extension Attribute.Argument: CustomStringConvertible {
    public var description: String {
        if let name = name {
            return "\(name): \(value)"
        } else {
            return "\(value)"
        }
    }
}

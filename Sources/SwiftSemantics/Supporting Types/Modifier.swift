import SwiftSyntax

/**
 A declaration modifier.

 A declaration may have one or more modifiers to
 specify access control (`private` / `public` / etc.),
 declare a type member (`class` / `static`),
 or designate its mutability (`nonmutating`).
 A declaration modifier may specify an additional detail
 within enclosing parentheses (`()`)
 following its name.

 For example,
 the following property declaration has two modifiers:

 ```swift
 public private(set) var title: String
 ```

 - The first modifier has a `name` equal to `"public"`,
   and a nil `detail`
 - The second modifier has a `name` equal to `"private"`
   and a `detail` equal to `"set"`
 */
public struct Modifier: Hashable, Codable {
    /// The declaration modifier name.
    public let name: String

    /// The modifier detail, if any.
    public let detail: String?
}

// MARK: - ExpressibleBySyntax

extension Modifier: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: DeclModifierSyntax) {
        name = node.name.text.trimmed
        detail = node.detail?.description
    }
}

// MARK: - CustomStringConvertible

extension Modifier: CustomStringConvertible {
    public var description: String {
        if let detail = detail {
            return "\(name)(\(detail))"
        } else {
            return name
        }
    }
}

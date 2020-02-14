import SwiftSyntax

/// A class deinitializer declaration.
public struct Deinitializer: Declaration, Hashable, Codable {
    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"deinit"`).
    public let keyword: String
}

// MARK: - ExpressibleBySyntax

extension Deinitializer: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: DeinitializerDeclSyntax) {
        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.deinitKeyword.text.trimmed
    }
}

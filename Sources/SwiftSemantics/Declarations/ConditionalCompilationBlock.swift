import SwiftSyntax

/// A conditional compilation block declaration.
public struct ConditionalCompilationBlock: Declaration, Hashable, Codable {
    /**
     The conditional compilation block branches.

     For example,
     the following compilation block declaration has two branches:

     ```swift
     #if true
     enum A {}
     #else
     enum B {}
     #endif
     ```

     The first branch has the keyword `#if` and condition `"true"`.
     The second branch has the keyword `#else` and no condition.
     */
    public let branches: [Branch]

    /// A conditional compilation block branch.
    public enum Branch: Hashable {
        /// An `#if` branch.
        case `if`(String)

        /// An `#elseif` branch.
        case `elseif`(String)

        /// An `#else` branch.
        case `else`

        init?(keyword: String, condition: String?) {
            switch (keyword, condition) {
            case let ("#if", condition?):
                self = .if(condition)
            case let ("#elseif", condition?):
                self = .elseif(condition)
            case ("#else", nil):
                self = .else
            default:
                return nil
            }
        }

        /// The branch keyword, either `"#if"`, `"#elseif"`, or `"#else"`.
        public var keyword: String {
            switch self {
            case .if:
                return "#if"
            case .elseif:
                return "#elseif"
            case .else:
                return "#else"
            }
        }

        /**
         The branch condition, if any.

         This value is present when `keyword` is equal to `"#if"` or `#elseif`
         and `nil` when `keyword` is  equal to `"#else"`.
         */
        public var condition: String? {
            switch self {
            case let .if(condition),
                 let .elseif(condition):
                return condition
            case .else:
                return nil
            }
        }
    }
}

// MARK: - ExpressibleBySyntax

extension ConditionalCompilationBlock: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: IfConfigDeclSyntax) {
        branches = node.clauses.map { Branch($0) }
    }
}

extension ConditionalCompilationBlock.Branch: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: IfConfigClauseSyntax) {
        let keyword = node.poundKeyword.text.trimmed
        let condition = node.condition?.description.trimmed
        self.init(keyword: keyword, condition: condition)!
    }
}

// MARK: - Codable

extension ConditionalCompilationBlock.Branch: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let keyword = try container.decode(String.self)
        let condition = try container.decodeIfPresent(String.self)
        self.init(keyword: keyword, condition: condition)!
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(keyword)
        try container.encode(condition)
    }
}

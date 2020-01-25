import SwiftSyntax

/// An operator precedence group declaration.
public struct PrecedenceGroup: Declaration, Hashable, Codable {
    /**
      The associativity of an operator,
      which determines how operators of the same precedence
      are grouped in the absence of parentheses.

      Consider the expression `a ~ b ~ c`:
      If the `~` operator is *left-associative*,
      then the expression is interpreted as `(a ~ b) ~ c`.
      If the `~` operator is *right-associative*,
      then the expression is interpreted as `a ~ (b ~ c)`.

      For example,
      the Swift subtraction operator (`-`) is *left-associative*,
      such that `5 - 7 - 2` evaluates to `-4` (`(5 - 7) - 2`)
      rather than `0` (`5 - (7 - 2)`).
     */
    public enum Associativity: String, Hashable, Codable {
        /// Left-associative (operations are grouped from the left).
        case left

        /// Right-associative (operations are grouped from the right).
        case right
    }

    /**
     The relation of operators to operators in other precedence groups,
     which determines the order in which
     operators of different precedence groups are evaluated
     in absence of parentheses.

     Consider the expression `a ⧓ b ⧗ c`.
     If the `⧓` operator has a *higher* precedence than `⧗`,
     then the expression is interpreted as `(a ⧓ b) ⧗ c`.
     If the `⧓` operator has a *lower* precedence than `⧗`,
     then the expression is interpreted as `a ⧓ (b ⧗ c)`.

     For example,
     Swift mathematical operators have the same inherent precedence
     as their corresponding arithmetic operations,
     such that `1 + 2 * 3` evaluates to `7` (`1 + (2 * 3)`)
     rather than `9` (`(1 + 2) * 3`).
     */
    public enum Relation: Hashable {
        /**
         The precedence group has *higher* precedence than
         the associated group names.
         */
        case higherThan([String])

        /**
        The precedence group has *lower* precedence than
        the associated group names.
        */
        case lowerThan([String])
    }

    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"precedencegroup"`)
    public let keyword: String

    /// The precedence group name.
    public let name: String

    /**
     Whether operators in the precedence group are folded into optional chains.

     For example,
     if `assignment` is `true`,
     the expression `entry?.count += 1`
     has the effect of `entry?(.count += 1)`;
     otherwise, the same expression is interpreted as `(entry?.count) += 1`
     and fails to type-check.
     */
    public let assignment: Bool?

    /// The associativity of operators in the precedence group.
    public let associativity: Associativity?

    /// The relation of operators to operators in other precedence groups.
    public let relations: [Relation]
}

// MARK: -

extension PrecedenceGroup.Relation: Comparable {
    public static func < (lhs: PrecedenceGroup.Relation, rhs: PrecedenceGroup.Relation) -> Bool {
        switch (lhs, rhs) {
        case (.lowerThan, .higherThan):
            return true
        case (.higherThan, .lowerThan):
            return false
        case let (.lowerThan(lpg), .lowerThan(rpg)),
             let (.higherThan(lpg), .higherThan(rpg)):
            return lpg.count < rpg.count || (lpg.count == rpg.count && lpg.sorted().joined(separator: ",") < rpg.sorted().joined(separator: ","))
        }
    }
}

extension PrecedenceGroup.Relation: Codable {
    private enum CodingKeys: String, CodingKey {
        case higherThan
        case lowerThan
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let others = try? container.decode([String].self, forKey: .higherThan) {
            self = .higherThan(others)
        } else if let others = try? container.decode([String].self, forKey: .lowerThan) {
            self = .lowerThan(others)
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Missing key 'higherThan' or 'lowerThan'")
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .higherThan(let others):
            try container.encode(others, forKey: .higherThan)
        case .lowerThan(let others):
            try container.encode(others, forKey: .lowerThan)
        }
    }
}

// MARK: - ExpressibleBySyntax

extension PrecedenceGroup: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: PrecedenceGroupDeclSyntax) {
        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.precedencegroupKeyword.withoutTrivia().text
        name = node.identifier.withoutTrivia().text

        var assignment: Bool?
        var associativity: Associativity?
        var relations: [Relation] = []

        for attribute in node.groupAttributes {
            switch attribute {
            case let attribute as PrecedenceGroupAssignmentSyntax:
                assignment = Bool(attribute)
            case let attribute as PrecedenceGroupAssociativitySyntax:
                associativity = Associativity(attribute)
            case let attribute as PrecedenceGroupRelationSyntax:
                if let relation = Relation(attribute) {
                    relations.append(relation)
                }
            default:
                continue
            }
        }

        self.assignment = assignment
        self.associativity = associativity
        self.relations = relations
    }
}

private extension Bool {
    /// Creates an instance initialized with the given syntax node.
    init?(_ node: PrecedenceGroupAssignmentSyntax) {
        self.init(node.flag.text)
    }
}

extension PrecedenceGroup.Associativity {
    /// Creates an instance initialized with the given syntax node.
    public init?(_ node: PrecedenceGroupAssociativitySyntax) {
        self.init(rawValue: node.value.description)
    }
}

extension PrecedenceGroup.Relation {
    /// Creates an instance initialized with the given syntax node.
    public init?(_ node: PrecedenceGroupRelationSyntax) {
        let otherNames = node.otherNames.map { $0.name.description }

        switch node.higherThanOrLowerThan.text {
        case "higherThan":
            self = .higherThan(otherNames)
        case "lowerThan":
            self = .lowerThan(otherNames)
        default:
            return nil
        }
    }
}

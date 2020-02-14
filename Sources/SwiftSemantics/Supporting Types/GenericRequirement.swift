import SwiftSyntax

/**
 A generic requirement.

 A generic type or function declaration may specifying one or more requirements
 in a generic where clause before the opening curly brace (`{`) its body.
 Each generic requirement establishes a relation between two type identifiers.

 For example,
 the following declaration specifies two generic requirements:

 ```swift
 func difference<C1: Collection, C2: Collection>(between lhs: C1, and rhs: C2) -> [C1.Element]
    where C1.Element: Equatable, C1.Element == C2.Element
 ```

 - The first generic requirement establishes a `conformance` relation
   between the generic types identified by `"C1.Element"` and `"Equatable"`
 - The second generic requirement establsihes a `sameType` relation
   between the generic types identified by `"C1.Element"` and `"C2.Element"`
 */
public struct GenericRequirement: Hashable, Codable {
    /**
     A relation between the two types identified
     in the generic requirement.

     For example,
     the declaration `struct S<T: Equatable>`
     has a single generic requirement
     that the type identified by `"T"`
     conforms to the type identified by `"Equatable"`.
     */
    public enum Relation: String, Hashable, Codable {
        /**
         The type identified on the left-hand side is equivalent to
         the type identified on the right-hand side of the generic requirement.
         */
        case sameType

        /**
         The type identified on the left-hand side conforms to
         the type identified on the right-hand side of the generic requirement.
        */
        case conformance
    }

    /// The relation between the two identified types.
    public let relation: Relation

    /// The identifier for the left-hand side type.
    public let leftTypeIdentifier: String

    /// The identifier for the right-hand side type.
    public let rightTypeIdentifier: String

    /**
     Creates and returns generic requirements initialized from a
     generic requirement list syntax node.

     - Parameter from: The generic requirement list syntax node, or `nil`.
     - Returns: An array of generic requirements, or `nil` if the node is `nil`.
     */
    public static func genericRequirements(from node: GenericRequirementListSyntax?) -> [GenericRequirement] {
        guard let node = node else { return [] }
        return node.compactMap { GenericRequirement($0) }
    }

    private init?(_ node: GenericRequirementSyntax) {
        if let node = SameTypeRequirementSyntax(node.body) {
            self.relation = .sameType
            self.leftTypeIdentifier = node.leftTypeIdentifier.description.trimmed
            self.rightTypeIdentifier = node.rightTypeIdentifier.description.trimmed
        } else if let node = ConformanceRequirementSyntax(node.body) {
            self.relation = .conformance
            self.leftTypeIdentifier = node.leftTypeIdentifier.description.trimmed
            self.rightTypeIdentifier = node.rightTypeIdentifier.description.trimmed
        } else {
            return nil
        }
    }
}

// MARK: - CustomStringConvertible

extension GenericRequirement: CustomStringConvertible {
    public var description: String {
        switch relation {
        case .sameType:
            return "\(leftTypeIdentifier) == \(rightTypeIdentifier)"
        case .conformance:
            return "\(leftTypeIdentifier): \(rightTypeIdentifier)"
        }
    }
}

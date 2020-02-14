import SwiftSyntax

/// An operator declaration.
public struct Operator: Declaration, Hashable, Codable {
    /// The kind of operator (prefix, infix, or postfix).
    public enum Kind: String, Hashable, Codable {
        /// A unary operator that comes before its operand.
        case prefix

        /// An binary operator that comes between its operands.
        case infix

        /// A unary operator that comes after its operand.
        case postfix

        init?(_ modifiers: [Modifier]) {
            let kinds = modifiers.compactMap { Kind(rawValue: $0.name) }
            assert(kinds.count <= 1)
            guard let kind = kinds.first else { return nil }
            self = kind
        }
    }

    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"operator"`).
    public let keyword: String

    /// The operator name.
    public let name: String

    /// The kind of operator (prefix, infix, or postfix).
    public var kind: Kind {
        return Kind(modifiers) ?? .infix
    }

    static func isValidIdentifier(_ string: String) -> Bool {
        func isValidHeadCharacter(_ character: Character) -> Bool {
            switch character {
            case // Basic Latin
                 "/", "=", "-", "+", "!", "*", "%",
                 "<", ">", "&", "|", "^", "?", "~",

                 // Latin-1 Supplement
                 "\u{00A1}",
                 "\u{00A2}",
                 "\u{00A3}",
                 "\u{00A4}",
                 "\u{00A5}",
                 "\u{00A6}",
                 "\u{00A7}",
                 "\u{00A9}",
                 "\u{00AB}",
                 "\u{00AC}",
                 "\u{00AE}",
                 "\u{00B0}",
                 "\u{00B1}",
                 "\u{00B6}",
                 "\u{00BB}",
                 "\u{00BF}",
                 "\u{00D7}",
                 "\u{00F7}",

                 // General Punctuation
                 "\u{2016}"..."\u{2017}",
                 "\u{2020}"..."\u{2027}",
                 "\u{2030}"..."\u{203E}",
                 "\u{2041}"..."\u{2053}",
                 "\u{2055}"..."\u{205E}",
                 "\u{2190}"..."\u{23FF}",

                 // Box Drawing
                 "\u{2500}"..."\u{257F}",

                 // Block Elements
                 "\u{2580}"..."\u{259F}",

                 // Miscellaneous Symbols
                 "\u{2600}"..."\u{26FF}",

                 // Dingbats
                 "\u{2700}"..."\u{2775}",
                 "\u{2794}"..."\u{2BFF}",

                 // Supplemental Punctuation
                 "\u{2E00}"..."\u{2E7F}",

                 // CJK Symbols and Punctuation
                 "\u{3001}"..."\u{3003}",
                 "\u{3008}"..."\u{3020}",
                 "\u{3030}":
                return true
            default:
                return false
            }
        }

        func isValidCharacter(_ character: Character) -> Bool {
            switch character {
                case "\u{0300}"..."\u{036F}",
                     "\u{1DC0}"..."\u{1DFF}",
                     "\u{20D0}"..."\u{20FF}",
                     "\u{FE00}"..."\u{FE0F}",
                     "\u{FE20}"..."\u{FE2F}",
                     "\u{E0100}"..."\u{E01EF}":
                return true
            default:
                return isValidHeadCharacter(character)
            }
        }

        guard let first = string.first,
            isValidHeadCharacter(first)
        else {
            return false
        }

        for character in string.suffix(from: string.startIndex) {
            guard isValidCharacter(character) else { return false }
        }

        return true
    }
}

// MARK: - ExpressibleBySyntax

extension Operator: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: OperatorDeclSyntax) {
        attributes = node.attributes?.compactMap{ $0 as? AttributeSyntax }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.operatorKeyword.text.trimmed
        name = node.identifier.text.trimmed
    }
}

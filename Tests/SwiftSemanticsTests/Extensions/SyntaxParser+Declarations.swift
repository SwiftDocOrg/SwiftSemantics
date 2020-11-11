import SwiftSyntax
import SwiftSemantics
import struct SwiftSemantics.Protocol

extension SyntaxParser {
    static func declarations<T: Declaration>(of type: T.Type, source: String) throws -> [T] {
        let collector = DeclarationCollector()
        let tree = try parse(source: source)
        collector.walk(tree)

        switch type {
        case is AssociatedType.Type:
            return collector.associatedTypes as! [T]
        case is Class.Type:
            return collector.classes as! [T]
        case is ConditionalCompilationBlock.Type:
            return collector.conditionalCompilationBlocks as! [T]
        case is Deinitializer.Type:
            return collector.deinitializers as! [T]
        case is Enumeration.Type:
            return collector.enumerations as! [T]
        case is Enumeration.Case.Type:
            return collector.enumerationCases as! [T]
        case is Extension.Type:
            return collector.extensions as! [T]
        case is Function.Type:
            return collector.functions as! [T]
        case is Import.Type:
            return collector.imports as! [T]
        case is Initializer.Type:
            return collector.initializers as! [T]
        case is Operator.Type:
            return collector.operators as! [T]
        case is PrecedenceGroup.Type:
            return collector.precedenceGroups as! [T]
        case is Protocol.Type:
            return collector.protocols as! [T]
        case is Structure.Type:
            return collector.structures as! [T]
        case is Subscript.Type:
            return collector.subscripts as! [T]
        case is Typealias.Type:
            return collector.typealiases as! [T]
        case is Variable.Type:
            return collector.variables as! [T]
        default:
            fatalError("Unimplemented for type \(T.self)")
        }
    }
}

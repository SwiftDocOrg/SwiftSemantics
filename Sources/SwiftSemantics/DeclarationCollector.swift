import SwiftSyntax

/**
 A Swift syntax visitor that collects declarations.

 Create an instance of `DeclarationCollector`
 and pass it by reference when walking an AST created by `SyntaxParser`
 to collect any visited declarations:

 ```swift
 import SwiftSyntax
 import SwiftSemantics

 let source = #"enum E {}"#

 var collector = DeclarationCollector()
 let tree = try SyntaxParser.parse(source: source)
 tree.walk(&collector)

 collector.enumerations.first?.name // "E"
 ```
 */
open class DeclarationCollector: SyntaxVisitor {
    /// The collected associated type declarations.
    public private(set) var associatedTypes: [AssociatedType] = []

    /// The collected class declarations.
    public private(set) var classes: [Class] = []

    /// The collected conditional compilation block declarations.
    public private(set) var conditionalCompilationBlocks: [ConditionalCompilationBlock] = []

    /// The collected deinitializer declarations.
    public private(set) var deinitializers: [Deinitializer] = []

    /// The collected enumeration declarations.
    public private(set) var enumerations: [Enumeration] = []

    /// The collected enumeration case declarations.
    public private(set) var enumerationCases: [Enumeration.Case] = []

    /// The collected extension declarations.
    public private(set) var extensions: [Extension] = []

    /// The collected function declarations.
    public private(set) var functions: [Function] = []

    /// The collected import declarations.
    public private(set) var imports: [Import] = []

    /// The collected initializer declarations.
    public private(set) var initializers: [Initializer] = []

    /// The collected operator declarations.
    public private(set) var operators: [Operator] = []

    /// The collected precedence group declarations.
    public private(set) var precedenceGroups: [PrecedenceGroup] = []

    /// The collected protocol declarations.
    public private(set) var protocols: [Protocol] = []

    /// The collected structure declarations.
    public private(set) var structures: [Structure] = []

    /// The collected subscript declarations.
    public private(set) var subscripts: [Subscript] = []

    /// The collected type alias declarations.
    public private(set) var typealiases: [Typealias] = []

    /// The collected variable declarations.
    public private(set) var variables: [Variable] = []

    /// Creates a new declaration collector.
    public override init() {}

    // MARK: - SyntaxVisitor

    /// Called when visiting an `AssociatedtypeDeclSyntax` node
    public override func visit(_ node: AssociatedtypeDeclSyntax) -> SyntaxVisitorContinueKind {
        associatedTypes.append(AssociatedType(node))
        return .skipChildren
    }

    /// Called when visiting a `ClassDeclSyntax` node
    public override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        classes.append(Class(node))
        return .visitChildren
    }

    /// Called when visiting a `DeinitializerDeclSyntax` node
    public override func visit(_ node: DeinitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        deinitializers.append(Deinitializer(node))
        return .skipChildren
    }

    /// Called when visiting an `EnumDeclSyntax` node
    public override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        enumerations.append(Enumeration(node))
        return .visitChildren
    }

    /// Called when visiting an `EnumCaseDeclSyntax` node
    public override func visit(_ node: EnumCaseDeclSyntax) -> SyntaxVisitorContinueKind {
        enumerationCases.append(contentsOf: Enumeration.Case.cases(from: node))
        return .skipChildren
    }

    /// Called when visiting an `ExtensionDeclSyntax` node
    public override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        extensions.append(Extension(node))
        return .visitChildren
    }

    /// Called when visiting a `FunctionDeclSyntax` node
    public override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        functions.append(Function(node))
        return .skipChildren
    }

    /// Called when visiting an `IfConfigDeclSyntax` node
    public override func visit(_ node: IfConfigDeclSyntax) -> SyntaxVisitorContinueKind {
        conditionalCompilationBlocks.append(ConditionalCompilationBlock(node))
        return .visitChildren
    }

    /// Called when visiting an `ImportDeclSyntax` node
    public override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        imports.append(Import(node))
        return .skipChildren
    }

    /// Called when visiting an `InitializerDeclSyntax` node
    public override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        initializers.append(Initializer(node))
        return .skipChildren
    }

    /// Called when visiting an `OperatorDeclSyntax` node
    public override func visit(_ node: OperatorDeclSyntax) -> SyntaxVisitorContinueKind {
        operators.append(Operator(node))
        return .skipChildren
    }

    /// Called when visiting a `PrecedenceGroupDeclSyntax` node
    public override func visit(_ node: PrecedenceGroupDeclSyntax) -> SyntaxVisitorContinueKind {
        precedenceGroups.append(PrecedenceGroup(node))
        return .skipChildren
    }

    /// Called when visiting a `ProtocolDeclSyntax` node
    public override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        protocols.append(Protocol(node))
        return .visitChildren
    }

    /// Called when visiting a `SubscriptDeclSyntax` node
    public override  func visit(_ node: SubscriptDeclSyntax) -> SyntaxVisitorContinueKind {
        subscripts.append(Subscript(node))
        return .skipChildren
    }

    /// Called when visiting a `StructDeclSyntax` node
    public override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        structures.append(Structure(node))
        return .visitChildren
    }

    /// Called when visiting a `TypealiasDeclSyntax` node
    public override func visit(_ node: TypealiasDeclSyntax) -> SyntaxVisitorContinueKind {
        typealiases.append(Typealias(node))
        return .skipChildren
    }

    /// Called when visiting a `VariableDeclSyntax` node
    public override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        variables.append(contentsOf: Variable.variables(from: node))
        return .skipChildren
    }
}

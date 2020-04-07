# SwiftSemantics

![CI][ci badge]
[![Documentation][documentation badge]][documentation]

SwiftSemantics is a package that lets you
parse Swift code into its constituent declarations.

Use [SwiftSyntax][swiftsyntax] to construct 
an abstract syntax tree from Swift source code,
then walk the AST with the provided `DeclarationCollector`
(or with your own `SyntaxVisitor`-conforming type)
and construct a `Declaration` value for each visited `DeclSyntax` node:

```swift
import SwiftSyntax
import SwiftSemantics

let source = #"""
import UIKit

class ViewController: UIViewController, UITableViewDelegate {
    enum Section: Int {
        case summary, people, places
    }

    var people: [People], places: [Place]

    @IBOutlet private(set) var tableView: UITableView!
}
"""#

var collector = DeclarationCollector()
let tree = try SyntaxParser.parse(source: source)
tree.walk(&collector)

// Import declarations
collector.imports.first?.pathComponents // ["UIKit"]

// Class declarations
collector.classes.first?.name // "ViewController"
collector.classes.first?.inheritance // ["UIViewController", "UITableViewDelegate"]

// Enumeration declarations
collector.enumerations.first?.name // "Section"

// Enumeration case declarations
collector.enumerationCases.count // 3
collector.enumerationCases.map { $0.name } // ["summary", "people", "places"])

// Variable (property) declarations
collector.variables.count // 3
collector.variables[0].name // "people"
collector.variables[1].typeAnnotation // "[Place]"
collector.variables[2].name // "tableView"
collector.variables[2].typeAnnotation // "UITableView!"
collector.variables[2].attributes.first?.name // "IBOutlet"
collector.variables[2].modifiers.first?.name // "private"
collector.variables[2].modifiers.first?.detail // "set"
```

> **Note**:
> For more information about SwiftSyntax,
> see [this article from NSHipster][nshipster swiftsyntax].

This package is used by [swift-doc][swift-doc] 
in coordination with [SwiftMarkup][swiftmarkup] 
to generate documentation for Swift projects
_([including this one][swiftsemantics documentation])_.

## Requirements

- Swift 5.1+

## Installation

### Swift Package Manager

Add the SwiftSemantics package to your target dependencies in `Package.swift`:

```swift
import PackageDescription

let package = Package(
  name: "YourProject",
  dependencies: [
    .package(
        url: "https://github.com/SwiftDocOrg/SwiftSemantics",
        from: "0.0.1"
    ),
    .package(
        url: "https://github.com/apple/swift-syntax.git", 
        from: "0.50100.0"
    ),
  ]
)
```

Then run the `swift build` command to build your project.

## Detailed Design

Swift defines 17 different kinds of declarations,
each of which is represented by a corresponding type in SwiftSemantics
that conforms to the 
[`Declaration` protocol](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Declaration):

- [`AssociatedType`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/AssociatedType)
- [`Class`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Class)
- [`ConditionalCompilationBlock`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/ConditionalCompilationBlock)
- [`Deinitializer`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Deinitializer)
- [`Enumeration`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Enumeration)
- [`Enumeration.Case`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Enumeration_Case)
- [`Extension`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Extension)
- [`Function`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Function)
- [`Import`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Import)
- [`Initializer`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Initializer)
- [`Operator`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Operator)
- [`PrecedenceGroup`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/PrecedenceGroup)
- [`Protocol`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Protocol)
- [`Structure`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Structure)
- [`Subscript`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Subscript)
- [`Typealias`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Typealias)
- [`Variable`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Variable)

> **Note**:
> Examples of each declaration are provided in the documentation
> as well as [unit tests](https://github.com/SwiftDocOrg/SwiftSemantics/tree/master/Tests/SwiftSemanticsTests).

The `Declaration` protocol itself has no requirements.
However, 
adopting types share many of the same properties, 
such as 
[`attributes`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Class#attributes),
[`modifiers`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Class#modifiers), 
and
[`keyword`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Class#keyword).

SwiftSemantics declaration types are designed to
maximize the information provided by SwiftSyntax,
closely following the structure and naming conventions of syntax nodes.
In some cases,
the library takes additional measures to refine results 
into more conventional interfaces.
For example,
the `PrecedenceGroup` type defines nested
[`Associativity`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/PrecedenceGroup_Associativity)
and
[`Relation`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/PrecedenceGroup_Relation)
enumerations for greater convenience and type safety.
However, in other cases,
results may be provided in their original, raw `String` values;
this decision is typically motivated either by 
concern for possible future changes to the language
or simply out of practicality.

For the most part,
these design decisions allow developers with even a basic understanding of Swift
to work productively with parsed declarations.
There are, however, some details that warrant further discussion:

### Type Members Aren't Provided as Properties

In Swift,
a class, enumeration, or structure may contain
one or more initializers, properties, subscripts, and methods, 
known as _members_.
A type can itself be a member of another type,
such as with `CodingKeys` enumerations nested within `Codable`-conforming types.
Likewise, a type may also have one or more associated type or type alias members.

SwiftSemantics doesn't provide built-in support for 
accessing type members directly from declaration values.
This is probably the most surprising 
(and perhaps contentious) 
design decision made in the library so far,
but we believe it to be the most reasonable option available.

One motivation comes down to delegation of responsibility:
`DeclarationCollector` and other types conforming to `SyntaxVisitor`
walk the abstract syntax tree,
respond to nodes as they're visited,
and decide whether to visit or skip a node's children. 
If a `Declaration` were to initialize its own members,
it would have the effect of overriding 
the tree walker's decision to visit or skip any children.
We believe that an approach involving direct member initialization is inflexible
and more likely to produce unexpected results.
For instance,
if you wanted to walk the AST to collect only Swift class declarations,
there wouldn't be a clear way to avoid needlessly initializing
the members of each top-level class
without potentially missing class declarations nested in other types.

But really, 
the controlling motivation has to do with extensions --- 
especially when used across multiple files in a module.
Consider the following two Swift files in the same module:

```swift
// First.swift
enum A { enum B { } }

// Second.swift
extension A.B { static func f(){} }
```

The first file declares two enumerations:
`A` and `B`, which is nested in `A`,
as well as protocol `P`.
The second file declares an extension on the type `A.B`
that provides a static function `f()`.
Depending on the order in which these files are processed,
the extension on `A.B` may precede any knowledge of `A` or `B`.
The capacity to reconcile these declarations exceeds
that of any individual declaration (or even a syntax walker),
and any intermediate results would necessarily be incomplete
and therefore misleading.

<details>
<summary><em>And if that weren't enough to dissuade you...</em></summary>

Consider what happens when we throw generically-constrained extensions 
and conditional compilation into the mix...

```swift
// Third.swift
#if platform(linux)
enum C {}
#else
protocol P {}
extension A.B where T: P { static func g(){} }
#end
```

</details>

Instead,
our approach delegates the responsibility for
reconciling declaration contexts to API consumers.

This is the approach we settled on for [swift-doc][swift-doc],
and it's worked reasonably well so far.
That said, 
we're certainly open to hearing any alternative approaches
and invite you to share any feedback about project architecture
by [opening a new Issue](https://github.com/SwiftDocOrg/SwiftSemantics/issues/new).

### Not All Language Features Are Encoded

Swift is a complex language with many different rules and concepts,
and not all of them are represented directly in SwiftSemantics.

Declaration membership, 
discussed in the previous section,
is one such example.
Another is how
declaration access modifiers like `public` and `private(set)`
aren't given any special treatment;
they're [`Modifier`](https://github.com/SwiftDocOrg/SwiftSemantics/wiki/Modifier) values 
like any other.

This design strategy keeps the library narrowly focused
and more adaptable to language evolution over time.

You can extend SwiftSemantics in your own code
to encode any missing language concepts that are relevant to your problem.
For example,
SwiftSemantics doesn't encode the concept of 
[property wrappers](https://nshipster.com/propertywrapper/),
but you could use it as the foundation of your own representation:

```swift
protocol PropertyWrapperType {
    var attributes: [Attribute] { get }
}

extension Class: PropertyWrapperType {}
extension Enumeration: PropertyWrapperType {}
extension Structure: PropertyWrapperType {}

extension PropertyWrapperType {
    var isPropertyWrapper: Bool {
        return attributes.contains { $0.name == "propertyWrapper" }
    }
}
```

### Declarations Don't Include Header Documentation or Source Location

Documentation comments,
like regular comments and whitespace,
are deemed by SwiftSyntax to be "trivia" for syntax nodes.
To keep this library narrowly focused,
we don't provide a built-in functionality for symbol documentation
(source location is omitted from declarations for similar reasons).

If you wanted to do this yourself,
you could subclass `DeclarationCollector`
and override the `visit` delegate methods
to retrieve, parse, and associate documentation comments
with their corresponding declaration.
Alternatively,
you can use [SwiftDoc][swift-doc],
which — in conjunction with [SwiftMarkup][swiftmarkup] —
_does_ offer this functionality.

## Known Issues

- Xcode 11 cannot run unit tests (<kbd>⌘</kbd><kbd>U</kbd>) 
  when opening the SwiftSemantics package directly,
  as opposed first to generating an Xcode project file with 
  `swift package generate-xcodeproj`.
  (The reported error is:
  `Library not loaded: @rpath/lib_InternalSwiftSyntaxParser.dylib`).
  As a workaround,
  you can run unit tests from the command line
  with `swift test`.

## License

MIT

## Contact

Mattt ([@mattt](https://twitter.com/mattt))

[swiftsyntax]: https://github.com/apple/swift-syntax
[nshipster swiftsyntax]: https://nshipster.com/swiftsyntax/
[swift-doc]: https://github.com/SwiftDocOrg/swift-doc
[swiftmarkup]: https://github.com/SwiftDocOrg/SwiftMarkup
[swiftsemantics documentation]: https://github.com/SwiftDocOrg/SwiftSemantics/wiki

[ci badge]: https://github.com/SwiftDocOrg/SwiftSemantics/workflows/CI/badge.svg
[documentation badge]: https://github.com/SwiftDocOrg/SwiftSemantics/workflows/Documentation/badge.svg
[documentation]: https://github.com/SwiftDocOrg/SwiftSemantics/wiki

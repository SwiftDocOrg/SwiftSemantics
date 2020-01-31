import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(AssociatedTypeTests.allTests),
            testCase(AttributeTests.allTests),
            testCase(ConditionalCompilationBlockTests.allTests),
            testCase(DeclarationCollectorTests.allTests),
            testCase(ExtensionTests.allTests),
            testCase(FunctionTests.allTests),
            testCase(GenericRequirementTests.allTests),
            testCase(InitializerTests.allTests),
            testCase(ImportTests.allTests),
            testCase(OperatorTests.allTests),
            testCase(ProtocolTests.allTests),
            testCase(StructureTests.allTests),
            testCase(SubscriptTests.allTests),
            testCase(VariableTests.allTests),
        ]
    }
#endif

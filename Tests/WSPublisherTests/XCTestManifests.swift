import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(WSPublisher1Tests.allTests),
    ]
}
#endif

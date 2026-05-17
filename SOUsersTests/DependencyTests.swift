import Foundation
import Testing

@testable import SOUsers

private enum TestStringKey: DependencyKey {
    static let liveValue = "live-deadbeef"
    static let testValue = "test-deadbeef"
}

private enum TestIntKey: DependencyKey {
    static let liveValue = 444
    static let testValue = 555
}

extension DependencyValues {
    fileprivate var testString: String {
        get { self[TestStringKey.self] }
        set { self[TestStringKey.self] = newValue }
    }
    fileprivate var testInt: Int {
        get { self[TestIntKey.self] }
        set { self[TestIntKey.self] = newValue }
    }
}

@Suite(.serialized)
struct DependencyValuesTests {
    init() {
        clearOverrides()
    }

    @Test
    func subscriptReturnsLiveValueWhenUnset() {
        var values = DependencyValues()
        #expect(values[TestStringKey.self] == "live-deadbeef")

        values[TestStringKey.self] = "new-deadbeef"
        #expect(values[TestStringKey.self] == "new-deadbeef")
    }

    @Test
    func mutatingOneKeyDoesNotAffectAnother() {
        var values = DependencyValues()
        values[TestStringKey.self] = "deadbeef"

        #expect(values[TestIntKey.self] == 444)
    }

    @Test
    func keyPathAndSubscriptAccessAreConsistent() {
        var values = DependencyValues()
        values.testString = "via-keypath"

        #expect(values[keyPath: \.testString] == "via-keypath")
        #expect(values[TestStringKey.self] == "via-keypath")
    }

    @Test
    func overridesAreNilByDefault() {
        #expect(DependencyContainer.overrides == nil)
    }

    @Test
    func resolveFallsBackToLiveValueWhenNothingIsSet() {
        #expect(DependencyContainer.resolve(\.testString) == "live-deadbeef")
        #expect(DependencyContainer.resolve(\.testInt) == 444)
    }

    @Test
    func overridesTakePrecedenceOverTaskLocalCurrent() {
        var values = DependencyValues()
        values.testString = "from-task-local"

        setOverrides { $0.testString = "overriden" }

        let resolved = DependencyContainer.$current.withValue(values) {
            DependencyContainer.resolve(\.testString)
        }

        #expect(resolved == "overriden")
    }

    @Test
    func setOverridesIsAdditive() {
        setOverrides { $0.testString = "first" }
        setOverrides { $0.testInt = 999 }

        #expect(DependencyContainer.resolve(\.testString) == "first")
        #expect(DependencyContainer.resolve(\.testInt) == 999)
    }

    @Test
    func setOverridesUpdatesExistingKey() {
        setOverrides { $0.testString = "first" }
        setOverrides { $0.testString = "second" }
        #expect(DependencyContainer.resolve(\.testString) == "second")
    }

    @Test
    func clearOverridesRestoresFallback() {
        setOverrides { $0.testString = "overridden" }
        #expect(DependencyContainer.resolve(\.testString) == "overridden")

        clearOverrides()
        #expect(DependencyContainer.overrides == nil)
        #expect(DependencyContainer.resolve(\.testString) == "live-deadbeef")
    }
}

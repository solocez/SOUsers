import Foundation

@propertyWrapper
struct Dependency<Value> {
    private let keyPath: KeyPath<DependencyValues, Value>

    init(_ keyPath: KeyPath<DependencyValues, Value>) {
        self.keyPath = keyPath
    }

    var wrappedValue: Value {
        DependencyContainer.resolve(keyPath)
    }
}

func setOverrides(_ update: (inout DependencyValues) -> Void) {
    var values = DependencyContainer.overrides ?? DependencyValues()
    update(&values)
    DependencyContainer.overrides = values
}

func clearOverrides() {
    DependencyContainer.overrides = nil
}

import Foundation

protocol DependencyKey {
    associatedtype Value
    static var liveValue: Value { get }
    static var testValue: Value { get }
}

struct DependencyValues {
    private var storage: [ObjectIdentifier: Any] = [:]

    subscript<K: DependencyKey>(key: K.Type) -> K.Value {
        get {
            if let value = storage[ObjectIdentifier(key)] as? K.Value {
                return value
            }
            return K.liveValue
        }
        set {
            storage[ObjectIdentifier(key)] = newValue
        }
    }
}

enum DependencyContainer {
    @TaskLocal
    static var current = DependencyValues()
}

// To be able overriding dependencies for tests and preview
extension DependencyContainer {
    nonisolated(unsafe) static var overrides: DependencyValues?

    static func resolve<Value>(_ keyPath: KeyPath<DependencyValues, Value>)
        -> Value
    {
        if let overrides {
            return overrides[keyPath: keyPath]
        }
        return current[keyPath: keyPath]
    }
}

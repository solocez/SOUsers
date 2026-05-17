import Foundation

// Persist to UserDefaults
extension Persistence: DependencyKey {
    static let liveValue = {
        let key = "soUsersFollowedIds"
        let defaults = UserDefaults.standard

        return Self(
            loadFollowedIds: {
                let raw = defaults.array(forKey: key) as? [Int] ?? []
                return Set(raw)
            },
            save: {
                defaults.set(Array($0), forKey: key)
                defaults.synchronize()
            }
        )
    }()
}

extension DependencyValues {
    var persistence: Persistence {
        get { self[Persistence.self] }
        set { self[Persistence.self] = newValue }
    }
}

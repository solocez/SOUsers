import Foundation

// In Memory persistence
extension Persistence {
    static let testValue = {
        actor State {
            private(set) var ids: Set<Int> = []

            func save(ids: Set<Int>) {
                self.ids = ids
            }
        }
        let state = State()
        
        return Self(
            loadFollowedIds: {
                await state.ids
            },
            save: {
                await state.save(ids: $0)
            }
        )
    }()
}

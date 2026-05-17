import Foundation

struct Persistence: Sendable {
    var loadFollowedIds: @concurrent @Sendable () async -> Set<Int>
    var save: @concurrent @Sendable (Set<Int>) async -> Void
}

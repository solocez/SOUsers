import Foundation

struct User: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let reputation: Int
    let profileImageURL: URL?
    var isFollowed: Bool
}

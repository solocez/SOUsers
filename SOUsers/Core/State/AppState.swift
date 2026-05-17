import UIKit

enum AppStateError: Error, Sendable {
    case operationFailed
}

@MainActor
protocol AppState {
    var users: [User] { get }

    func appendUsers(_ users: [User]) async
    func getUser(at index: Int) throws -> User
    func toggleFollow(userId: Int) async throws -> User
}

@Observable
final class AppStateImpl: AppState {
    @ObservationIgnored
    @Dependency(\.persistence) private var persistence

    private(set) var users: [User] = []

    init() { }

    func appendUsers(_ users: [User]) async {
        let followed = await persistence.loadFollowedIds()

        let merged = users.map { user in
            var adjusted = user
            adjusted.isFollowed = followed.contains(adjusted.id)
            return adjusted
        }

        self.users.append(contentsOf: merged)
    }

    func getUser(at index: Int) throws -> User {
        guard let user = users[safe: index] else {
            throw AppStateError.operationFailed
        }
        return user
    }

    func toggleFollow(userId: Int) async throws -> User {
        guard let index = users.firstIndex(where: { $0.id == userId }) else {
            throw AppStateError.operationFailed
        }
        users[index].isFollowed.toggle()

        var followed = await persistence.loadFollowedIds()

        if users[index].isFollowed {
            followed.insert(userId)
        } else {
            followed.remove(userId)
        }

        await persistence.save(followed)

        return users[index]
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        return self[index]
    }
}

enum AppStateKey: DependencyKey {
    static let liveValue: AppState = AppStateImpl()
    static let testValue: AppState = AppStateImpl()
}

extension DependencyValues {
    var appState: AppState {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
}

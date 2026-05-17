import Foundation
import UIKit

@Observable
final class UsersListViewModel {
    @ObservationIgnored
    @Dependency(\.apiClient) private var apiClient
    @ObservationIgnored
    @Dependency(\.appState) private var appState

    @ObservationIgnored
    var onUserSelected: (@MainActor @Sendable (User) -> Void)?

    private(set) var state = ViewModelState.idle
    @ObservationIgnored
    var loadUsersTask: Task<Void, Never>?

    init() {}

    deinit {
        loadUsersTask?.cancel()
    }

    func loadUsers() {
        loadUsersTask = Task { [weak self] in
            guard let self else { return }
            state = .inProgress
            do {
                let users = try await apiClient.fetchUsers()
                await appState.appendUsers(users)
                state = .ready
            } catch {
                state = .error(AppError(error))
            }
        }
    }

    func selectUser(userIdx: Int) {
        state = .inProgress
        do {
            let user = try appState.getUser(at: userIdx)
            onUserSelected?(user)
            state = .ready
        } catch {
            state = .error(AppError(error))
        }
    }

    func toggleFollow(user: User) async {
        _ = try? await appState.toggleFollow(userId: user.id)
    }
}

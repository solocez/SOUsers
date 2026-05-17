import UIKit

@Observable
final class UserDetailsViewModel {
    @ObservationIgnored
    @Dependency(\.appState) private var appState

    private(set) var state: ViewModelState = .idle
    private(set) var user: User

    init(user: User) {
        self.user = user
    }

    func loadUser() {
        state = .ready
    }

    func toggleFollow() async {
        do {
            state = .inProgress
            user = try await appState.toggleFollow(userId: user.id)
            state = .ready
        } catch {
            state = .error(AppError(error))
        }
    }
}

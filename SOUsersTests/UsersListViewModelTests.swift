import Foundation
import Testing

@testable import SOUsers

@MainActor
@Suite(.serialized)
struct UsersListViewModelTests {
    init() {
        clearOverrides()
    }

    // LoadUsers

    @Test
    func loadsUsers() async {
        let appState = AppStateImpl()
        let apiClient = ApiClient(fetchUsers: {
            [mockUser1, mockUser2]
        })

        await Persistence.testValue.save([])
        setOverrides {
            $0.persistence = Persistence.testValue
            $0.appState = appState
            $0.apiClient = apiClient
        }

        let model = UsersListViewModel()
        model.loadUsers()
        await model.loadUsersTask?.value

        #expect(model.state == .ready)
        #expect(appState.users.count == 2)
        #expect(appState.users.map(\.id) == [mockUser1.id, mockUser2.id])
    }

    @Test
    func setsStateToErrorWhenApiClientFails() async {
        let appState = AppStateImpl()
        let apiClient = ApiClient(fetchUsers: {
            throw ApiClientError.opearationFailed
        })

        await Persistence.testValue.save([])
        setOverrides {
            $0.persistence = Persistence.testValue
            $0.appState = appState
            $0.apiClient = apiClient
        }

        let model = UsersListViewModel()
        model.loadUsers()
        await model.loadUsersTask?.value

        #expect(model.state.error != nil)
        #expect(appState.users.isEmpty)
    }

    // Select Users

    @Test
    func callsOnUserSelected() async {
        let appState = AppStateImpl()
        await Persistence.testValue.save([])
        setOverrides {
            $0.persistence = Persistence.testValue
            $0.appState = appState
        }
        await appState.appendUsers([mockUser1, mockUser2])

        let model = UsersListViewModel()
        var selected: User?
        model.onUserSelected = { selected = $0 }
        model.selectUser(userIdx: 1)

        #expect(selected?.id == mockUser2.id)
        #expect(model.state == .ready)
    }

    class AppStateErrorImpl: AppState {
        var users: [User] = []
        init() {}
        func setup() async {}
        func appendUsers(_ users: [User]) async {}
        func getUser(at index: Int) throws -> User {
            throw AppStateError.operationFailed
        }
        func toggleFollow(userId: Int) async throws -> User { mockUser1 }
    }

    @Test
    func setsStateToErrorWhenIndexIsOutOfBounds() async {
        let appState = AppStateErrorImpl()
        await Persistence.testValue.save([])
        setOverrides {
            $0.persistence = Persistence.testValue
            $0.appState = appState
        }
        await appState.appendUsers([mockUser1])

        let model = UsersListViewModel()
        var selected: User?
        model.onUserSelected = { selected = $0 }

        model.selectUser(userIdx: 0)

        #expect(model.state.error != nil)
        #expect(selected == nil)
    }
}

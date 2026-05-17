import Foundation
import Testing

@testable import SOUsers

@MainActor
@Suite(.serialized)
struct AppStateTests {
    init() {
        clearOverrides()
    }

    // AppendUsers

    @Test
    func appendsUsersWithIsFollowedFalseWhenPersistenceIsEmpty() async {
        setOverrides { $0.persistence = Persistence.testValue }

        let state = AppStateImpl()
        await state.appendUsers([
            mockUser1,
            mockUser2,
        ])

        #expect(state.users.count == 2)
        #expect(state.users.allSatisfy { $0.isFollowed == false })
    }

    @Test
    func marksUserAsFollowedWhenIdIsInPersistedSet() async {
        await Persistence.testValue.save([1])
        setOverrides { $0.persistence = Persistence.testValue }

        let state = AppStateImpl()
        await state.appendUsers([
            mockUser1,
            mockUser2,
        ])

        #expect(state.users.map(\.isFollowed) == [true, false])
    }

    @Test
    func overlaysFollowStateOverIncomingFlag() async {
        await Persistence.testValue.save([2])
        setOverrides { $0.persistence = Persistence.testValue }

        var user1 = mockUser1
        user1.isFollowed = true

        let state = AppStateImpl()
        await state.appendUsers([
            user1,  // isFollowed == true
            mockUser2,  // isFollowed == false
        ])

        #expect(state.users[0].isFollowed == false)
        #expect(state.users[1].isFollowed == true)
    }

    @Test
    func emptyInputLeavesUsersUnchanged() async {
        setOverrides { $0.persistence = Persistence.testValue }

        let state = AppStateImpl()
        await state.appendUsers([mockUser1])
        await state.appendUsers([])

        #expect(state.users.count == 1)
        #expect(state.users[0].id == 1)
    }

    // Get Users

    @Test
    func returnsUserAtFirstIndex() async throws {
        setOverrides { $0.persistence = Persistence.testValue }

        let state = AppStateImpl()
        await state.appendUsers([mockUser1, mockUser2])

        let user = try state.getUser(at: 0)
        #expect(user.id == mockUser1.id)
    }

    @Test
    func throwsWhenIndexIsOutOfBounds() async {
        setOverrides { $0.persistence = Persistence.testValue }

        let state = AppStateImpl()
        await state.appendUsers([mockUser1, mockUser2])

        #expect(throws: AppStateError.operationFailed) {
            _ = try state.getUser(at: 2)
        }
    }

    @Test
    func throwsWhenUsersIsEmpty() async {
        setOverrides { $0.persistence = Persistence.testValue }

        let state = AppStateImpl()
        #expect(throws: AppStateError.operationFailed) {
            _ = try state.getUser(at: 0)
        }
    }

    // Togle Follow

    @Test
    func togglesFromFalseToTrue() async throws {
        await Persistence.testValue.save([])
        setOverrides { $0.persistence = Persistence.testValue }

        let state = AppStateImpl()
        await state.appendUsers([mockUser1])

        let returned = try await state.toggleFollow(userId: mockUser1.id)

        #expect(returned.isFollowed == true)
        #expect(state.users[0].isFollowed == true)
    }

    @Test
    func persistsFollowedIdAfterToggle() async throws {
        await Persistence.testValue.save([])
        setOverrides { $0.persistence = Persistence.testValue }

        let state = AppStateImpl()
        await state.appendUsers([mockUser1, mockUser2])

        _ = try await state.toggleFollow(userId: mockUser1.id)

        let stored = await Persistence.testValue.loadFollowedIds()
        #expect(stored.contains(mockUser1.id))
        #expect(stored.contains(mockUser2.id) == false)
    }

    @Test
    func throwsWhenUserIdIsNotInUsers() async {
        setOverrides { $0.persistence = Persistence.testValue }

        let state = AppStateImpl()
        await state.appendUsers([mockUser1])

        await #expect(throws: AppStateError.operationFailed) {
            _ = try await state.toggleFollow(userId: 333)
        }
    }
}

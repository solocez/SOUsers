extension ApiClient {
    static let testValue = {
        @Dependency(\.appState) var appState

        return Self(
            fetchUsers: {
                let result = [
                    User(
                        id: 1,
                        name: "John",
                        reputation: 1,
                        profileImageURL: nil,
                        isFollowed: false
                    ),
                    User(
                        id: 2,
                        name: "Bil",
                        reputation: 2,
                        profileImageURL: nil,
                        isFollowed: false
                    ),
                    User(
                        id: 3,
                        name: "Kirk",
                        reputation: 3,
                        profileImageURL: nil,
                        isFollowed: false
                    ),
                ]
                await appState.appendUsers(result)
                return result
            }
        )
    }()

    static let noConnectionValue = {
        Self(
            fetchUsers: {
                throw ApiClientError.opearationFailed
            }
        )
    }()
}

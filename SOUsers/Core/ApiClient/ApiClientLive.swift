import Foundation

extension ApiClient: DependencyKey {
    static let liveValue = {
        Self(
            fetchUsers: {
                guard let url = await URLComponents.fetchUsers(pageSize: 20)
                else {
                    throw ApiClientError.opearationFailed
                }

                let (data, response) = try await URLSession.shared.data(
                    from: url
                )
                guard let http = response as? HTTPURLResponse else {
                    throw ApiClientError.opearationFailed
                }
                guard (200..<300).contains(http.statusCode) else {
                    throw ApiClientError.opearationFailed
                }

                return try await JSONDecoder().users(data)
            }
        )
    }()
}

extension DependencyValues {
    var apiClient: ApiClient {
        get { self[ApiClient.self] }
        set { self[ApiClient.self] = newValue }
    }
}

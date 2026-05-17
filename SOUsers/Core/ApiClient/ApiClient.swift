import Foundation

enum ApiClientError: Error, Sendable {
    case opearationFailed
}

struct ApiClient: Sendable {
    var fetchUsers: @concurrent @Sendable () async throws -> [User]
}

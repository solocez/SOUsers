import Foundation

struct UsersResponseDTO: Decodable {
    let items: [UserDTO]
}

struct UserDTO: Decodable {
    let userId: Int
    let displayName: String
    let reputation: Int
    let profileImage: URL?
}

extension JSONDecoder {
    func users(_ data: Data) throws -> [User] {
        keyDecodingStrategy = .convertFromSnakeCase
        do {
            let dto = try decode(UsersResponseDTO.self, from: data)
            return dto.items.map { item in
                User(
                    id: item.userId,
                    name: item.displayName,
                    reputation: item.reputation,
                    profileImageURL: item.profileImage,
                    isFollowed: false
                )
            }
        } catch {
            throw ApiClientError.opearationFailed
        }
    }
}

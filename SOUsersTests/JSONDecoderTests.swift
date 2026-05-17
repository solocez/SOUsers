import Foundation
import Testing

@testable import SOUsers

struct JSONDecoderTests {
    // Happy Path
    @Test
    func decodesRealisticGetUsersResponse() throws {
        let data = Data(realGetUsersResponse.utf8)
        let users = try JSONDecoder().users(data)

        try #require(users.count == 20)
        let user = users[0]
        #expect(user.id == 22656)
        #expect(user.name == "Jon Skeet")
        #expect(user.reputation == 1_527_241)
        #expect(
            user.profileImageURL
                == URL(
                    string:
                        "https://www.gravatar.com/avatar/6d8ebb117e8d83d74ea95fbdd0f87e13?s=256&d=identicon&r=PG"
                )
        )
        #expect(user.isFollowed == false)
    }

    @Test
    func decodesEmptyItemsResponse() throws {
        let data = Data(
            """
                { 
                    "items": [
                    ]
                }
            """.utf8
        )
        let users = try JSONDecoder().users(data)
        #expect(users.isEmpty)
    }

    @Test
    func missingProfileImageDecodesToNil() throws {
        let data = Data(
            """
            {
                "items": [
                    { 
                        "user_id": 1, 
                        "display_name": "A", 
                        "reputation": 100 
                    }
                ]
            }
            """.utf8
        )

        let user = try #require(try JSONDecoder().users(data).first)
        #expect(user.profileImageURL == nil)
    }

    @Test
    func throwsOnMalformedJSON() {
        let data = Data(
            """
            {
            deadbeef
                "items": [
                    { 
                        "user_id": deadbeef, 
                        "display_name": "A", 
                        "reputation": 100 
                    }
                ]
            }
            """.utf8
        )
        #expect(throws: ApiClientError.opearationFailed) {
            _ = try JSONDecoder().users(data)
        }
    }

    @Test
    func throwsWhenFieldHasWrongType() {
        // user_id is wrong here - has to be Int
        let data = Data(
            """
            {
                "items": [
                    { 
                        "user_id": deadbeef, 
                        "display_name": "A", 
                        "reputation": 100 
                    }
                ]
            }
            """.utf8
        )
        #expect(throws: ApiClientError.opearationFailed) {
            _ = try JSONDecoder().users(data)
        }
    }

    @Test
    func throwsOnEmptyData() {
        let data = Data()
        #expect(throws: ApiClientError.opearationFailed) {
            _ = try JSONDecoder().users(data)
        }
    }
}

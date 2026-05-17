import Foundation

let mockUser1Id = 1
let mockUser1 = User(
    id: mockUser1Id,
    name: "deadbeef",
    reputation: 1,
    profileImageURL: URL(string: "https://i.sstatic.net/I4fiW.jpg?s=256")!,
    isFollowed: false
)

let mockUser2Id = 2
let mockUser2 = User(
    id: mockUser2Id,
    name: "deadbeef-deadbeef",
    reputation: 2,
    profileImageURL: URL(string: "https://www.gravatar.com/avatar/e514b017977ebf742a418cac697d8996?s=256&d=identicon&r=PG")!,
    isFollowed: false
)

let dataUnavailableUserId = -3
let dataUnavailableUser = User(
    id: dataUnavailableUserId,
    name: "Unknown",
    reputation: 0,
    profileImageURL: URL(string: "https://www.gravatar.com/avatar/e514b017977ebf742a418cac697d8996?s=256&d=identicon&r=PG")!,
    isFollowed: false
)

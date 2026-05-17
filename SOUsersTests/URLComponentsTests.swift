import Foundation
import Testing

@testable import SOUsers

// Ideally has to be tested with Snapshot tests - like PointFree's snapshot.
// It allows testing URLs as well.
struct URLComponentsTests {
    @Test
    func getUsesHTTPSScheme() throws {
        let url = try #require(URLComponents.fetchUsers())
        #expect(url.scheme == "https")
        #expect(url.host == "api.stackexchange.com")
        #expect(url.path == "/2.3/users")

        #expect(queryValue(of: url, named: "page") == "1")
        #expect(queryValue(of: url, named: "pagesize") == "20")
        #expect(queryValue(of: url, named: "order") == "desc")
        #expect(queryValue(of: url, named: "sort") == "reputation")
        #expect(queryValue(of: url, named: "site") == "stackoverflow")

        #expect(
            url.absoluteString
                == "https://api.stackexchange.com/2.3/users?page=1&pagesize=20&order=desc&sort=reputation&site=stackoverflow"
        )
    }

    @Test(arguments: [1, 10, 50, 100])
    func customPageSize(pageSize: Int) throws {
        let url = try #require(URLComponents.fetchUsers(pageSize: pageSize))
        #expect(queryValue(of: url, named: "pagesize") == String(pageSize))
    }

    // MARK: - Private

    private func queryItems(of url: URL) -> [URLQueryItem] {
        URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
            ?? []
    }

    private func queryValue(of url: URL, named name: String) -> String? {
        queryItems(of: url).first(where: { $0.name == name })?.value
    }
}

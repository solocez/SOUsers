import Foundation

extension URLComponents {
    static func fetchUsers(pageSize: Int = 20) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.stackexchange.com"
        components.path = "/2.3/users"
        components.queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "pagesize", value: String(pageSize)),
            URLQueryItem(name: "order", value: "desc"),
            URLQueryItem(name: "sort", value: "reputation"),
            URLQueryItem(name: "site", value: "stackoverflow"),
        ]
        return components.url
    }
}
